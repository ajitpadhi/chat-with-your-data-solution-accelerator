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
param storageAccountName string = ''

@description('Managed identity configuration.')
param managedIdentities object = { systemAssigned: true }

@description('Optional. Docker image name to use for container function apps.')
param dockerFullImageName string = ''

@description('App settings as name-value pairs (object).')
param appSettings object = {}

@description('Site configuration object.')
param siteConfig object = {}

@description('Runtime stack.')
param runtimeStack string = 'python'

@description('Runtime version.')
param runtimeVersion string = '3.11'

@description('Resource kind for the site (e.g., functionapp,linux).')
param kind string = 'functionapp,linux'

@description('Enable Azure telemetry collection.')
param enableTelemetry bool = true

// ============================================================================
// Variables
// ============================================================================
var baseAppSettings = {
  AzureWebJobsStorage__accountName: storageAccountName
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: runtimeStack
}

var mergedAppSettings = union(baseAppSettings, appSettings, { WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false' })

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
    kind: kind
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
      linuxFxVersion: !empty(dockerFullImageName) ? 'DOCKER|${dockerFullImageName}' : '${toUpper(runtimeStack)}|${runtimeVersion}'
    }, siteConfig)
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
