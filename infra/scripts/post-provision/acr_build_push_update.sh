#!/usr/bin/env bash
#
# Builds the v2 application container images, pushes them to the per-deployment ACR,
# and updates the Container Apps (frontend, backend) and Function App.
#
# Usage:
#   ./infra/scripts/post-provision/acr_build_push_update.sh <resource-group> [--tag TAG]
#
# Examples:
#   ./infra/scripts/post-provision/acr_build_push_update.sh "rg-cwyd-dev"
#   ./infra/scripts/post-provision/acr_build_push_update.sh "rg-cwyd-dev" --tag v1.0.0
#

set -euo pipefail
export MSYS_NO_PATHCONV=1

RESOURCE_GROUP=""
IMAGE_TAG="latest"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$RESOURCE_GROUP" ]]; then
                RESOURCE_GROUP="$1"
            else
                echo "Unexpected argument: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$RESOURCE_GROUP" ]]; then
    read -rp "Enter the resource group name: " RESOURCE_GROUP
    if [[ -z "$RESOURCE_GROUP" ]]; then
        echo "ERROR: Resource group name is required." >&2
        exit 1
    fi
fi

# Script lives at <repo>/infra/scripts/post-provision/, so walk up 3 levels for the repo root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." >/dev/null 2>&1 && pwd)"

# -------------------------------------------------------
# Load ACR values from .azure/<env>/.env when present (optional convenience)
# -------------------------------------------------------
if [[ -d "${REPO_ROOT}/.azure" ]]; then
    while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# && "$line" =~ = ]]; then
            key="${line%%=*}"
            value="${line#*=}"
            value="${value%\"}"
            value="${value#\"}"
            case "$key" in
                AZURE_CONTAINER_REGISTRY_NAME) ACR_NAME="$value" ;;
                AZURE_CONTAINER_REGISTRY_ENDPOINT) ACR_LOGIN_SERVER="$value" ;;
                AZURE_RESOURCE_GROUP) AZURE_RESOURCE_GROUP="$value" ;;
            esac
        fi
    done < <(find "${REPO_ROOT}/.azure" -name '.env' -type f 2>/dev/null | head -1 | xargs cat 2>/dev/null || true)
fi

echo ""
echo "=============================================="
echo " Build, Push & Update Images"
echo " Resource Group : ${RESOURCE_GROUP}"
echo " Image Tag      : ${IMAGE_TAG}"
echo " Repo Root      : ${REPO_ROOT}"
echo "=============================================="
echo ""

# -------------------------------------------------------
# Discover shared resources
# -------------------------------------------------------
echo "Discovering resources in resource group '${RESOURCE_GROUP}'..."

if [[ -z "${ACR_NAME:-}" ]]; then
    ACR_NAME=$(az acr list --resource-group "$RESOURCE_GROUP" --query "[0].name" --output tsv 2>/dev/null || true)
fi

if [[ -z "${ACR_NAME:-}" ]]; then
    echo "ERROR: No Azure Container Registry found in resource group '${RESOURCE_GROUP}'." >&2
    echo "Run 'azd provision' to create infrastructure first." >&2
    exit 1
fi

if [[ -z "${ACR_LOGIN_SERVER:-}" ]]; then
    ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
fi

MI_CLIENT_ID=$(az identity list --resource-group "$RESOURCE_GROUP" --query "[0].clientId" --output tsv 2>/dev/null || true)

if [[ -z "${MI_CLIENT_ID:-}" ]]; then
    echo "ERROR: No user-assigned managed identity found in resource group '${RESOURCE_GROUP}'." >&2
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

echo "  ACR             : $ACR_LOGIN_SERVER"
echo "  Managed identity: $MI_CLIENT_ID"
echo ""

# -------------------------------------------------------
# Helper: update a Container App (v2 frontend + backend)
# Bicep already wires the ACR registry with the UAMI, so only the image is set here.
# -------------------------------------------------------
update_container_app() {
    local app_name="$1"
    local image_name="$2"

    local full_image="${ACR_LOGIN_SERVER}/${image_name}:${IMAGE_TAG}"
    local revision_suffix="$(date +%Y%m%d%H%M%S)"
    echo "  Updating Container App: $app_name"
    echo "    Image: $full_image"
    echo "    Revision suffix: $revision_suffix"

    az containerapp update \
        --name "$app_name" \
        --resource-group "$RESOURCE_GROUP" \
        --image "$full_image" \
        --revision-suffix "$revision_suffix" \
        --output none
}

# -------------------------------------------------------
# Helper: update a Function App (v2 function-docker on App Service Plan)
# -------------------------------------------------------
update_function_app() {
    local app_name="$1"
    local image_name="$2"

    local full_image="${ACR_LOGIN_SERVER}/${image_name}:${IMAGE_TAG}"
    echo "  Updating Function App: $app_name"
    echo "    Image: $full_image"

    az functionapp config container set \
        --name "$app_name" \
        --resource-group "$RESOURCE_GROUP" \
        --image "$full_image" \
        --registry-server "https://${ACR_LOGIN_SERVER}" \
        --output none

    local resource_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Web/sites/${app_name}"
    az resource update \
        --ids "$resource_id" \
        --set "properties.siteConfig.acrUseManagedIdentityCreds=true" \
        --set "properties.siteConfig.acrUserManagedIdentityID=$MI_CLIENT_ID" \
        --output none

    az functionapp restart \
        --name "$app_name" \
        --resource-group "$RESOURCE_GROUP"
}

# -------------------------------------------------------
# Build and push images
# v2 image map: matches docker/ Dockerfiles at repo root and bicep-defined image names.
# -------------------------------------------------------
IMAGE_DEFINITIONS=(
    "docker/Dockerfile.frontend:rag-frontend"
    "docker/Dockerfile.backend:rag-backend"
    "docker/Dockerfile.functions:rag-functions"
)

echo ""
echo "--- REMOTE BUILD (ACR Tasks - no local Docker required) ---"
echo "    Note: your Azure identity needs Contributor or AcrPush access on the ACR."
echo ""

for dockerfile in "${IMAGE_DEFINITIONS[@]}"; do
    dockerfile_path="${dockerfile%%:*}"
    image_name="${dockerfile##*:}"
    full_tag="${image_name}:${IMAGE_TAG}"

    echo "[$image_name] Submitting remote build to ACR '$ACR_NAME' ..."
    az acr build \
        --registry "$ACR_NAME" \
        --image "$full_tag" \
        --file "${REPO_ROOT}/${dockerfile_path}" \
        "$REPO_ROOT"

    echo "[$image_name] OK"
done

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
echo ""
echo "=============================================="
echo " Build & Push Complete"
echo "=============================================="
echo " Images pushed to ${ACR_LOGIN_SERVER}:"
echo "   ${ACR_LOGIN_SERVER}/rag-frontend:${IMAGE_TAG}"
echo "   ${ACR_LOGIN_SERVER}/rag-backend:${IMAGE_TAG}"
echo "   ${ACR_LOGIN_SERVER}/rag-functions:${IMAGE_TAG}"

# -------------------------------------------------------
# Discover and update Container Apps (frontend + backend)
# -------------------------------------------------------
echo ""
echo "Updating Container Apps..."

CA_LIST_JSON=$(az containerapp list --resource-group "$RESOURCE_GROUP" --output json 2>/dev/null || true)

for pair in "frontend:rag-frontend" "backend:rag-backend"; do
    service_tag="${pair%%:*}"
    image_name="${pair##*:}"

    APP_NAME=""
    if [[ -n "$CA_LIST_JSON" ]]; then
        # Prefer azd-service-name tag
        APP_NAME=$(echo "$CA_LIST_JSON" | jq -r --arg tag "$service_tag" \
            '.[] | select(.tags and .tags."azd-service-name" == $tag) | .name' | head -1 || true)

        # Fallback: name pattern (Bicep uses ca-<service>-<suffix>)
        if [[ -z "$APP_NAME" ]]; then
            APP_NAME=$(echo "$CA_LIST_JSON" | jq -r --arg tag "$service_tag" \
                '.[] | select(.name | startswith("ca-" + $tag + "-")) | .name' | head -1 || true)
        fi
    fi

    if [[ -z "$APP_NAME" ]]; then
        echo "  WARNING: No Container App for azd-service-name='$service_tag' in RG '$RESOURCE_GROUP' - skipping."
        continue
    fi

    update_container_app "$APP_NAME" "$image_name"
done

# -------------------------------------------------------
# Discover and update the Function App
# -------------------------------------------------------
echo ""
echo "Updating Function App..."
FUNC_LIST=$(az functionapp list --resource-group "$RESOURCE_GROUP" --output json 2>/dev/null || true)
FUNC_APP_NAME=""

if [[ -n "$FUNC_LIST" ]]; then
    # Prefer azd-service-name tag
    FUNC_APP_NAME=$(echo "$FUNC_LIST" | jq -r '.[] | select(.tags and .tags."azd-service-name" == "function") | .name' | head -1 || true)

    # Fallback: name pattern (Bicep uses func-<suffix>-docker)
    if [[ -z "$FUNC_APP_NAME" ]]; then
        FUNC_APP_NAME=$(echo "$FUNC_LIST" | jq -r '.[] | select(.name | startswith("func-") and endswith("-docker")) | .name' | head -1 || true)
    fi

    # Last resort: first function app in the RG
    if [[ -z "$FUNC_APP_NAME" ]]; then
        FUNC_APP_NAME=$(echo "$FUNC_LIST" | jq -r '.[0].name' 2>/dev/null || true)
    fi
fi

if [[ -z "$FUNC_APP_NAME" ]]; then
    echo "  WARNING: No Function App found in resource group '${RESOURCE_GROUP}' - skipping."
else
    update_function_app "$FUNC_APP_NAME" "rag-functions"
fi

echo ""
echo "=============================================="
echo " ACR Build, Push & Update complete"
echo "=============================================="
