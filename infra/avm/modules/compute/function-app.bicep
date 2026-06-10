// ============================================================================
// Module: Azure Function App (AVM)
// AVM Module: avm/res/web/site:0.23.1
// ============================================================================

@description('Name of the function app.')
param name string

@description('Azure region for deployment.')
param location string

@description('Resource tags.')
param tags object = {}

@description('Resource ID of the App Service Plan.')
param serverFarmResourceId string

@description('Name of the storage account.')
param storageAccountName string

@description('Managed identity configuration.')
param managedIdentities object = {
  systemAssigned: true
}

@description('The client ID of the user assigned identity for the function app. Required for AZURE_CLIENT_ID when using a user assigned managed identity.')
param userAssignedIdentityClientId string = ''

@description('Docker image name to use for container function apps.')
param dockerFullImageName string = ''

@description('App settings as name-value pairs.')
param appSettings object = {}

@description('Site configuration object.')
param siteConfig object = {}

@description('Runtime stack.')
param runtimeStack string = 'python'

@description('Runtime version.')
param runtimeVersion string = '3.11'

@description('Optional kind for the function app resource. Defaults to functionapp,linux or functionapp,linux,container when a docker image is used.')
param kind string = ''

@description('Diagnostic settings for monitoring.')
param diagnosticSettings array = []

@description('Subnet resource ID for VNet integration.')
param virtualNetworkSubnetId string = ''

@description('Public network access setting.')
param publicNetworkAccess string = 'Enabled'

@description('Enable Azure telemetry collection.')
param enableTelemetry bool = true

// ============================================================================
// Variables
// ============================================================================
var useDocker = !empty(dockerFullImageName)
var effectiveKind = !empty(kind) ? kind : (useDocker ? 'functionapp,linux,container' : 'functionapp,linux')
var linuxFxVersion = useDocker ? dockerFullImageName : '${toUpper(runtimeStack)}|${runtimeVersion}'
var mergedAppSettings = union({
  AzureWebJobsStorage__accountName: storageAccountName
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: runtimeStack
  AZURE_CLIENT_ID: userAssignedIdentityClientId
}, appSettings)

// ============================================================================
// Function App (AVM)
// ============================================================================
module functionApp 'br/public:avm/res/web/site:0.23.1' = {
  name: take('avm.res.web.site.func.${name}', 64)
  params: {
    name: name
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    kind: effectiveKind
    serverFarmResourceId: serverFarmResourceId
    storageAccountRequired: false
    managedIdentities: managedIdentities
    configs: [
      {
        name: 'appsettings'
        properties: mergedAppSettings
      }
    ]
    siteConfig: union({
      linuxFxVersion: linuxFxVersion
    }, siteConfig)
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetResourceId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
    diagnosticSettings: !empty(diagnosticSettings) ? diagnosticSettings : []
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('The name of the function app.')
output name string = functionApp.outputs.name

@description('The resource ID of the function app.')
output resourceId string = functionApp.outputs.resourceId

@description('The default hostname of the function app.')
output defaultHostName string = functionApp.outputs.defaultHostname

@description('The principal ID of the system-assigned managed identity.')
output principalId string = functionApp.outputs.?systemAssignedMIPrincipalId ?? ''
