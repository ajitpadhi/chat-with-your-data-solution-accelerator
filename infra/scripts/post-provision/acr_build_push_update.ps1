<#
.SYNOPSIS
    Builds the v2 application container images, pushes them to the per-deployment ACR,
    and updates the Container Apps (frontend, backend) and Function App.
.DESCRIPTION
    Uses ACR Tasks (remote build - no local Docker required) to build three images
    from docker/Dockerfile.frontend, docker/Dockerfile.backend, docker/Dockerfile.functions,
    then updates the deployed services discovered by their azd-service-name tags.
.PARAMETER ResourceGroupName
    The name of the Azure resource group containing the deployed resources.
.PARAMETER Tag
    Image tag to apply. Defaults to 'latest'.
.EXAMPLE
    .\infra\scripts\post-provision\acr_build_push_update.ps1 -ResourceGroupName "rg-cwyd-dev"
.EXAMPLE
    .\infra\scripts\post-provision\acr_build_push_update.ps1 -ResourceGroupName "rg-cwyd-dev" -Tag v1.0.0
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$Tag = "latest"
)

# -------------------------------------------------------
# Resolve repo root (script lives in infra/scripts/post-provision/)
# -------------------------------------------------------
$ErrorActionPreference = "Stop"

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { chcp 65001 > $null 2>$null } catch {}
$env:PYTHONIOENCODING = 'utf-8'
$env:PYTHONUTF8 = '1'

# Auto-load ACR values from .azure/<env>/.env when present (optional convenience).
# Script lives at <repo>/infra/scripts/post-provision/, so walk up 3 levels for the repo root.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir))
$azureDir = Join-Path $RepoRoot '.azure'
if (Test-Path $azureDir) {
    $envFiles = Get-ChildItem -Path $azureDir -Recurse -Filter '.env' -File -ErrorAction SilentlyContinue
    foreach ($ef in $envFiles) {
        try {
            $lines = Get-Content $ef.FullName | Where-Object { $_ -and ($_ -match '=') }
            $kv = @{}
            foreach ($l in $lines) {
                if ($l -match '^\s*([A-Za-z0-9_]+)\s*=\s*"?(.*?)"?\s*$') { $kv[$matches[1]] = $matches[2] }
            }
            if ($kv.ContainsKey('AZURE_CONTAINER_REGISTRY_NAME')) { $AcrName = $kv['AZURE_CONTAINER_REGISTRY_NAME'] }
            if ($kv.ContainsKey('AZURE_CONTAINER_REGISTRY_ENDPOINT')) { $AcrLoginServer = $kv['AZURE_CONTAINER_REGISTRY_ENDPOINT'] }
            if ($AcrName) {
                Write-Host "Loaded env values from $($ef.FullName)"
                Write-Host "  AZURE_CONTAINER_REGISTRY_NAME=$AcrName"
                if ($AcrLoginServer) { Write-Host "  AZURE_CONTAINER_REGISTRY_ENDPOINT=$AcrLoginServer" }
                break
            }
        } catch {
            # ignore parse errors
        }
    }
}

# v2 image map: matches docker/ Dockerfiles at repo root and bicep-defined image names.
# (Bicep hard-codes rag-functions for the function app; frontend/backend are updated by this script.)
$Images = @(
    [pscustomobject]@{ Name = 'rag-frontend';  Dockerfile = 'docker/Dockerfile.frontend' },
    [pscustomobject]@{ Name = 'rag-backend';   Dockerfile = 'docker/Dockerfile.backend' },
    [pscustomobject]@{ Name = 'rag-functions'; Dockerfile = 'docker/Dockerfile.functions' }
)

Write-Host "=============================================="
Write-Host " Build, Push & Update Images"
Write-Host " Resource Group : $ResourceGroupName"
Write-Host " Image Tag      : $Tag"
Write-Host " Repo Root      : $RepoRoot"
Write-Host "=============================================="

# ---------------------------------------------------------------------------
# Discover shared resources
# ---------------------------------------------------------------------------
Write-Host "Discovering resources in resource group '$ResourceGroupName'..."

if (-not $AcrName) {
    $AcrName = az acr list `
        --resource-group $ResourceGroupName `
        --query "[0].name" `
        --output tsv 2>$null
}

if ([string]::IsNullOrWhiteSpace($AcrName)) {
    Write-Error "No Azure Container Registry found in resource group '$ResourceGroupName'.`nRun 'azd provision' to create infrastructure first."
    exit 1
}

if (-not $AcrLoginServer) {
    $AcrLoginServer = "$AcrName.azurecr.io"
}

$MiClientId = az identity list `
    --resource-group $ResourceGroupName `
    --query "[0].clientId" `
    --output tsv 2>$null

if ([string]::IsNullOrWhiteSpace($MiClientId)) {
    Write-Error "No user-assigned managed identity found in resource group '$ResourceGroupName'."
    exit 1
}

$SubscriptionId = az account show --query id --output tsv

Write-Host "  ACR             : $AcrLoginServer"
Write-Host "  Managed identity: $MiClientId"
Write-Host ""

# ---------------------------------------------------------------------------
# Helper: get deployment outputs from Bicep (fallback discovery)
# ---------------------------------------------------------------------------
function Get-DeploymentOutput {
    param(
        [string]$OutputName,
        [string]$ResourceGroup
    )

    try {
        $deploymentName = az deployment group list `
            --resource-group $ResourceGroup `
            --query "[0].name" `
            --output tsv 2>$null

        if ([string]::IsNullOrWhiteSpace($deploymentName)) {
            return $null
        }

        $output = az deployment group show `
            --name $deploymentName `
            --resource-group $ResourceGroup `
            --query "properties.outputs.$OutputName.value" `
            --output tsv 2>$null

        return $output
    } catch {
        return $null
    }
}

# ---------------------------------------------------------------------------
# ACR public access helpers (WAF auto-detect, try/finally pattern from CGSA)
# ---------------------------------------------------------------------------
$script:AcrOpenedForBuild = $false

function Enable-AcrPublicAccess {
    $publicAccess = az acr show -n $AcrName --query publicNetworkAccess --output tsv 2>$null
    if ($publicAccess -eq 'Disabled') {
        Write-Host "===== ACR public access is disabled (WAF mode) - temporarily enabling for build =====" -ForegroundColor Yellow
        az acr update -n $AcrName --public-network-enabled true --default-action Allow --output none --only-show-errors
        if ($LASTEXITCODE -ne 0) { Write-Error "Failed to enable ACR public access."; exit 1 }
        $script:AcrOpenedForBuild = $true
        Write-Host "Waiting 45s for network rule propagation..." -ForegroundColor Yellow
        Start-Sleep -Seconds 45
    }
}

function Restore-AcrPublicAccess {
    if ($script:AcrOpenedForBuild) {
        Write-Host "===== Re-locking ACR (disabling public network access) =====" -ForegroundColor Yellow
        az acr update -n $AcrName --public-network-enabled false --default-action Deny --output none --only-show-errors
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to re-disable ACR public access. Re-lock manually: az acr update -n $AcrName --public-network-enabled false --default-action Deny"
        }
    }
}

# -------------------------------------------------------
# Build and push
# -------------------------------------------------------
Write-Host ""
Write-Host "--- REMOTE BUILD (ACR Tasks - no local Docker required) ---"
Write-Host "    Note: your Azure identity needs Contributor or AcrPush access on the ACR."
Write-Host ""

try {
    Enable-AcrPublicAccess

    foreach ($img in $Images) {
        $FullTag    = "$($img.Name):${Tag}"
        $Dockerfile = Join-Path $RepoRoot $img.Dockerfile

        Write-Host "[$($img.Name)] Submitting remote build to ACR '$AcrName' ..."
        az acr build `
            --registry  $AcrName `
            --image     $FullTag `
            --file      $Dockerfile `
            $RepoRoot
        if ($LASTEXITCODE -ne 0) { Write-Error "Remote build failed for $($img.Name)."; exit 1 }

        Write-Host "[$($img.Name)] OK Done"
    }
} finally {
    Restore-AcrPublicAccess
}

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
Write-Host ""
Write-Host "=============================================="
Write-Host " Build & Push Complete"
Write-Host "=============================================="
Write-Host " Images pushed to ${AcrLoginServer}:"
foreach ($img in $Images) {
    Write-Host "   ${AcrLoginServer}/$($img.Name):${Tag}"
}

# ---------------------------------------------------------------------------
# Helper: update a Container App (v2 frontend + backend)
# Bicep already wires the ACR registry with the UAMI, so only the image is set here.
# ---------------------------------------------------------------------------
function Update-ContainerApp {
    param(
        [string]$AppName,
        [string]$ImageName
    )

    $FullImage = "${AcrLoginServer}/${ImageName}:${Tag}"
    $RevisionSuffix = Get-Date -Format "yyyyMMddHHmmss"
    Write-Host "  Updating Container App: $AppName"
    Write-Host "    Image: $FullImage"
    Write-Host "    Revision suffix: $RevisionSuffix"

    az containerapp update `
        --name $AppName `
        --resource-group $ResourceGroupName `
        --image $FullImage `
        --revision-suffix $RevisionSuffix `
        --output none
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to update Container App '$AppName'."; exit 1 }
}

# ---------------------------------------------------------------------------
# Helper: update a Function App (v2 function-docker on App Service Plan)
# ---------------------------------------------------------------------------
function Update-FunctionApp {
    param(
        [string]$AppName,
        [string]$ImageName
    )

    $FullImage = "${AcrLoginServer}/${ImageName}:${Tag}"
    Write-Host "  Updating Function App: $AppName"
    Write-Host "    Image: $FullImage"

    # Use the dedicated command so az builds "DOCKER|<image>" linuxFxVersion
    # internally, avoiding a literal '|' on the command line.
    az functionapp config container set `
        --name $AppName `
        --resource-group $ResourceGroupName `
        --image $FullImage `
        --registry-server "https://${AcrLoginServer}" `
        --output none

    # Enable managed-identity based ACR pull via config/web REST API.
    # NOTE: az resource update --set does NOT persist acrUserManagedIdentityID
    # (known platform bug), so we use az rest PATCH on the config/web endpoint.
    $ResourceId = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroupName}/providers/Microsoft.Web/sites/${AppName}"
    $ConfigUri = "https://management.azure.com${ResourceId}/config/web?api-version=2023-12-01"
    $Body = @{ properties = @{ acrUseManagedIdentityCreds = $true; acrUserManagedIdentityID = $MiClientId } } | ConvertTo-Json -Depth 5
    $BodyFile = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $BodyFile -Value $Body -Encoding utf8
    az rest --method patch --uri $ConfigUri --body "@$BodyFile" --output none
    Remove-Item $BodyFile -ErrorAction SilentlyContinue

    az functionapp restart `
        --name $AppName `
        --resource-group $ResourceGroupName
}

# ---------------------------------------------------------------------------
# Discover and update Container Apps (frontend + backend)
# ---------------------------------------------------------------------------
$ContainerAppServiceMap = @(
    [pscustomobject]@{ ServiceTag = 'frontend'; ImageName = 'rag-frontend' },
    [pscustomobject]@{ ServiceTag = 'backend';  ImageName = 'rag-backend' },
    [pscustomobject]@{ ServiceTag = 'function';  ImageName = 'rag-functions' }
)

Write-Host ""
Write-Host "Updating Container Apps..."

$ContainerAppListJson = az containerapp list --resource-group $ResourceGroupName --output json 2>$null
$containerApps = @()
if (-not [string]::IsNullOrWhiteSpace($ContainerAppListJson)) {
    $containerApps = $ContainerAppListJson | ConvertFrom-Json
}

foreach ($entry in $ContainerAppServiceMap) {
    $AppName = ($containerApps `
        | Where-Object { $_.tags -and $_.tags.'azd-service-name' -eq $entry.ServiceTag } `
        | Select-Object -First 1).name

    # Fallback: name pattern (Bicep uses ca-<service>-<suffix>)
    if ([string]::IsNullOrWhiteSpace($AppName)) {
        $AppName = ($containerApps `
            | Where-Object { $_.name -like "ca-$($entry.ServiceTag)-*" } `
            | Select-Object -First 1).name
    }

    if ([string]::IsNullOrWhiteSpace($AppName)) {
        Write-Host "  WARNING: No Container App for azd-service-name='$($entry.ServiceTag)' in RG '$ResourceGroupName' - skipping."
        continue
    }

    Update-ContainerApp -AppName $AppName -ImageName $entry.ImageName
}

Write-Host ""
Write-Host "=============================================="
Write-Host " ACR Build, Push & Update complete"
Write-Host "=============================================="
