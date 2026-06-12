targetScope = 'resourceGroup'

@description('Optional. A unique application/solution name for all resources in this deployment. This should be 3-16 characters long.')
@minLength(3)
@maxLength(16)
param solutionName string = 'cwyd'

@maxLength(5)
@description('Optional. A unique text value for the solution. This is used to ensure resource names are unique for global resources. Defaults to a 5-character substring of the unique string generated from the subscription ID, resource group name, and solution name.')
param solutionUniqueText string = take(uniqueString(subscription().id, resourceGroup().name, solutionName), 5)

@allowed([
  'australiaeast'
  'eastus2'
  'japaneast'
  'uksouth'
])
@metadata({ azd: { type: 'location' } })
@description('Required. Azure region for all services. Regions are restricted to guarantee compatibility with paired regions and replica locations for data redundancy and failover scenarios based on articles [Azure regions list](https://learn.microsoft.com/azure/reliability/regions-list) and [Azure Database for PostgreSQL Flexible Server - Azure Regions](https://learn.microsoft.com/azure/postgresql/flexible-server/overview#azure-regions). Note: In the "Deploy to Azure" interface, you will see both "Region" and "Location" fields - "Region" is only for deployment metadata while "Location" (this parameter) determines where your actual resources are deployed.')
param location string

@description('Optional. Existing Log Analytics Workspace Resource ID.')
param existingLogAnalyticsWorkspaceId string = ''

var solutionSuffix = toLower(trim(replace(
  replace(
    replace(replace(replace(replace('${solutionName}${solutionUniqueText}', '-', ''), '_', ''), '.', ''), '/', ''),
    ' ',
    ''
  ),
  '*',
  ''
)))

@description('Optional. Name of App Service plan.')
var hostingPlanName string = 'asp-${solutionSuffix}'

@description('Optional. The pricing tier for the App Service plan.')
@allowed([
  'B2'
  'B3'
  'S2'
  'S3'
])
param hostingPlanSku string = 'B3'

@description('Optional. The type of database to deploy (cosmos or postgres).')
@allowed([
  'PostgreSQL'
  'CosmosDB'
])
param databaseType string = 'PostgreSQL'

@description('Azure Cosmos DB Account Name.')
var azureCosmosDBAccountName string = 'cosmos-${solutionSuffix}'

@description('Azure Postgres DB Account Name.')
var azurePostgresDBAccountName string = 'psql-${solutionSuffix}'

@description('Name of Web App.')
var websiteName string = 'app-${solutionSuffix}'

@description('Name of Admin Web App.')
var adminWebsiteName string = '${websiteName}-admin'

@description('Name of Application Insights.')
var applicationInsightsName string = 'appi-${solutionSuffix}'

@description('Name of the Workbook.')
var workbookDisplayName string = 'workbook-${solutionSuffix}'

@description('Optional. Use semantic search.')
param azureSearchUseSemanticSearch bool = false

@description('Optional. Semantic search config.')
param azureSearchSemanticSearchConfig string = 'default'

@description('Optional. Is the index prechunked.')
param azureSearchIndexIsPrechunked string = 'false'

@description('Optional. Top K results.')
param azureSearchTopK string = '5'

@description('Optional. Enable in domain.')
param azureSearchEnableInDomain string = 'true'

@description('Optional. Id columns.')
param azureSearchFieldId string = 'id'

@description('Optional. Content columns.')
param azureSearchContentColumn string = 'content'

@description('Optional. Vector columns.')
param azureSearchVectorColumn string = 'content_vector'

@description('Optional. Filename column.')
param azureSearchFilenameColumn string = 'filename'

@description('Optional. Search filter.')
param azureSearchFilter string = ''

@description('Optional. Title column.')
param azureSearchTitleColumn string = 'title'

@description('Optional. Metadata column.')
param azureSearchFieldsMetadata string = 'metadata'

@description('Optional. Source column.')
param azureSearchSourceColumn string = 'source'

@description('Optional. Text column.')
param azureSearchTextColumn string = 'text'

@description('Optional. Layout Text column.')
param azureSearchLayoutTextColumn string = 'layoutText'

@description('Optional. Chunk column.')
param azureSearchChunkColumn string = 'chunk'

@description('Optional. Offset column.')
param azureSearchOffsetColumn string = 'offset'

@description('Optional. Url column.')
param azureSearchUrlColumn string = 'url'

@description('Optional. Whether to use Azure Search Integrated Vectorization. If the database type is PostgreSQL, set this to false.')
param azureSearchUseIntegratedVectorization bool = false

@description('Optional. Name of Azure OpenAI Resource.')
var azureOpenAIResourceName string = 'oai-${solutionSuffix}'

@description('Optional. Name of Azure OpenAI Resource SKU.')
param azureOpenAISkuName string = 'S0'

@description('Optional. Azure OpenAI Model Deployment Name.')
param azureOpenAIModel string = 'gpt-4.1'

@description('Optional. Azure OpenAI Model Name.')
param azureOpenAIModelName string = 'gpt-4.1'

@description('Optional. Azure OpenAI Model Version.')
param azureOpenAIModelVersion string = '2025-04-14'

@description('Optional. Azure OpenAI Model Capacity - See here for more info  https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/quota.')
param azureOpenAIModelCapacity int = 150

@description('Optional. Whether to enable the use of a vision LLM and Computer Vision for embedding images. If the database type is PostgreSQL, set this to false.')
param useAdvancedImageProcessing bool = false

@description('Optional. The maximum number of images to pass to the vision model in a single request.')
param advancedImageProcessingMaxImages int = 1

@description('Optional. Orchestration strategy: openai_function or semantic_kernel or langchain str. If you use a old version of turbo (0301), please select langchain. If the database type is PostgreSQL, set this to sementic_kernel.')
@allowed([
  'openai_function'
  'semantic_kernel'
  'langchain'
])
param orchestrationStrategy string = 'semantic_kernel'

@description('Optional. Chat conversation type: custom or byod. If the database type is PostgreSQL, set this to custom.')
@allowed([
  'custom'
  'byod'
])
param conversationFlow string = 'custom'

@description('Optional. Azure OpenAI Temperature.')
param azureOpenAITemperature string = '0'

@description('Optional. Azure OpenAI Top P.')
param azureOpenAITopP string = '1'

@description('Optional. Azure OpenAI Max Tokens.')
param azureOpenAIMaxTokens string = '1000'

@description('Optional. Azure OpenAI Stop Sequence.')
param azureOpenAIStopSequence string = '\\n'

@description('Optional. Azure OpenAI System Message.')
param azureOpenAISystemMessage string = 'You are an AI assistant that helps people find information.'

@description('Optional. Azure OpenAI Api Version.')
param azureOpenAIApiVersion string = '2024-02-01'

@description('Optional. Whether or not to stream responses from Azure OpenAI.')
param azureOpenAIStream string = 'true'

@description('Optional. Azure OpenAI Embedding Model Deployment Name.')
param azureOpenAIEmbeddingModel string = 'text-embedding-3-small'

@description('Optional. Azure OpenAI Embedding Model Name.')
param azureOpenAIEmbeddingModelName string = 'text-embedding-3-small'

@description('Optional. Azure OpenAI Embedding Model Version.')
param azureOpenAIEmbeddingModelVersion string = '1'

@description('Optional. Azure OpenAI Embedding Model Capacity - See here for more info https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/quota .')
param azureOpenAIEmbeddingModelCapacity int = 100

@description('Optional. Azure Search vector field dimensions. Must match the embedding model dimensions. 1536 for text-embedding-3-small, 3072 for text-embedding-3-large. See https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-azure-openai-embedding#supported-dimensions-by-modelname.(Only for databaseType=CosmosDB)')
param azureSearchDimensions string = '1536'

@description('Optional. Name of Computer Vision Resource (if useAdvancedImageProcessing=true).')
var computerVisionName string = 'cv-${solutionSuffix}'

@description('Optional. Name of Computer Vision Resource SKU (if useAdvancedImageProcessing=true).')
@allowed([
  'F0'
  'S1'
])
param computerVisionSkuName string = 'S1'

@description('Optional. Location of Computer Vision Resource (if useAdvancedImageProcessing=true).')
@allowed([
  // List taken from https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/how-to/image-retrieval?tabs=python#prerequisites
  'eastus'
  'westus'
  'koreacentral'
  'francecentral'
  'northeurope'
  'westeurope'
  'southeastasia'
  ''
])
param computerVisionLocation string = ''

@description('Optional. Azure Computer Vision Vectorize Image API Version.')
param computerVisionVectorizeImageApiVersion string = '2024-02-01'

@description('Optional. Azure Computer Vision Vectorize Image Model Version.')
param computerVisionVectorizeImageModelVersion string = '2023-04-15'

@description('Azure AI Search Resource.')
var azureAISearchName string = 'srch-${solutionSuffix}'

@description('Optional. The SKU of the search service you want to create. E.g. free or standard.')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param azureSearchSku string = 'standard'

@description('Azure AI Search Index.')
var azureSearchIndex string = 'index-${solutionSuffix}'

@description('Azure AI Search Indexer.')
var azureSearchIndexer string = 'indexer-${solutionSuffix}'

@description('Azure AI Search Datasource.')
var azureSearchDatasource string = 'datasource-${solutionSuffix}'

@description('Optional. Azure AI Search Conversation Log Index.')
param azureSearchConversationLogIndex string = 'conversations'

@description('Name of Storage Account.')
var storageAccountName string = 'st${solutionSuffix}'

@description('Name of Function App for Batch document processing.')
var functionName string = 'func-${solutionSuffix}'

@description('Azure Form Recognizer Name.')
var formRecognizerName string = 'di-${solutionSuffix}'

@description('Azure Content Safety Name.')
var contentSafetyName string = 'cs-${solutionSuffix}'

@description('Azure Speech Service Name.')
var speechServiceName string = 'spch-${solutionSuffix}'

@description('Optional. A new GUID string generated for this deployment. This can be used for unique naming if needed.')
param newGuidString string = newGuid()

@description('Optional. Principal object for user or service principal to assign application roles. Format: {"id":"<object-id>", "name":"<name-or-upn>", "type":"User|Group|ServicePrincipal"}')
param principal object = {
  id: '' // Principal ID
  name: '' // Principal name
  type: 'User' // Principal type ('User', 'Group', or 'ServicePrincipal')
}

@description('Optional. Application Environment.')
param appEnvironment string = 'Prod'

@description('Optional. Hosting model for the web apps. This value is fixed as "container", which uses prebuilt containers for faster deployment.')
param hostingModel string = 'container'

@description('Optional. The log level for application logging. This setting controls the verbosity of logs emitted by the application. Allowed values are CRITICAL, ERROR, WARN, INFO, and DEBUG. The default value is INFO.')
@allowed([
  'CRITICAL'
  'ERROR'
  'WARN'
  'INFO'
  'DEBUG'
])
param logLevel string = 'INFO'

@description('Optional. List of comma-separated languages to recognize from the speech input. Supported languages are listed here: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=stt#supported-languages.')
param recognizedLanguages string = 'en-US,fr-FR,de-DE,it-IT'

@description('Optional. The tags to apply to all deployed Azure resources.')
param tags resourceInput<'Microsoft.Resources/resourceGroups@2025-04-01'>.tags = {}

@description('Optional. Enable purge protection for applicable resources, aligned with the Well Architected Framework recommendations. Defaults to false.')
param enablePurgeProtection bool = false

@description('Optional. Enable monitoring applicable resources, aligned with the Well Architected Framework recommendations. This setting enables Application Insights and Log Analytics and configures all the resources applicable resources to send logs. Defaults to false.')
param enableMonitoring bool = false

var blobContainerName = 'documents'
var queueName = 'doc-processing'
var clientKey = '${uniqueString(guid(subscription().id, deployment().name))}${newGuidString}'
var eventGridSystemTopicName = 'evgt-${solutionSuffix}'

@description('Optional. Image version tag to use.')
param appversion string = 'latest_waf' // Update GIT deployment branch

@description('OpenAI and Semantic Kernel prompt values.')
param openAISystemPrompts object

var registryName = 'cwydcontainerreg' // Update Registry name

var allTags = union(
  {
    'azd-env-name': solutionName
  },
  tags
)

var existingTags = resourceGroup().tags ?? {}

@description('Optional. Created by user name.')
param createdBy string = contains(deployer(), 'userPrincipalName')
  ? split(deployer().userPrincipalName, '@')[0]
  : deployer().objectId

// ============== //
// Resources      //
// ============== //

// ========== Resource Group Tag ========== //
resource resourceGroupTags 'Microsoft.Resources/tags@2025-04-01' = {
  name: 'default'
  properties: {
    tags: union(existingTags, allTags, {
      TemplateName: 'CWYD'
      Type: 'Non-WAF'
      CreatedBy: createdBy
    })
  }
}

// ========== Managed Identity ========== //
module managedIdentityModule './modules/identity/managed-identity.bicep' = {
  name: take('module.managed-identity.${solutionName}', 64)
  params: {
    solutionName: solutionSuffix
    location: location
    tags: tags
  }
}

// ========== Monitoring (Log Analytics + Application Insights) ========== //
var useExistingLogAnalytics = !empty(existingLogAnalyticsWorkspaceId)

// Existing workspace reference (for cross-subscription support)
resource existingLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = if (useExistingLogAnalytics) {
  name: split(existingLogAnalyticsWorkspaceId, '/')[8]
  scope: resourceGroup(split(existingLogAnalyticsWorkspaceId, '/')[2], split(existingLogAnalyticsWorkspaceId, '/')[4])
}

// Resolve workspace resource ID and name — existing or new
var logAnalyticsWorkspaceResourceId = useExistingLogAnalytics
  ? existingLogAnalyticsWorkspace.id
  : (enableMonitoring ? log_analytics!.outputs.resourceId : '')
var logAnalyticsWorkspaceName = useExistingLogAnalytics
  ? split(existingLogAnalyticsWorkspaceId, '/')[8]
  : (enableMonitoring ? log_analytics!.outputs.name : '')

// WAF: Diagnostic settings helper — reused across modules
var monitoringDiagnosticSettings = enableMonitoring ? [{ workspaceResourceId: logAnalyticsWorkspaceResourceId }] : []


// ========== Log Analytics module ========== //
module log_analytics './modules/monitoring/log-analytics.bicep' = if (enableMonitoring && !useExistingLogAnalytics) {
  name: take('module.log-analytics.${solutionName}', 64)
  params: {
    solutionName: solutionSuffix
    location: location
  }
  scope: resourceGroup(resourceGroup().name)
}

// ========== Application Insights module ========== //
module app_insights './modules/monitoring/app-insights.bicep' = if (enableMonitoring) {
  name: take('module.app-insights.${solutionName}', 64)
  params: {
    solutionName: solutionSuffix
    location: location
    workspaceResourceId: logAnalyticsWorkspaceResourceId
  }
  scope: resourceGroup(resourceGroup().name)
}

module applicationInsightsDashboard './modules/monitoring/portal-dashboard.bicep' = if (enableMonitoring) {
  name: take('module.portal-dashboard.${solutionName}', 64)
  params: {
    solutionName: applicationInsightsName
    location: location
    tags: tags
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              colSpan: 2
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'id'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/AspNetOverviewPinnedPart'
              asset: {
                idInputName: 'id'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'overview'
            }
          }
          {
            position: {
              x: 2
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/ProactiveDetectionAsyncPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'ProactiveDetection'
            }
          }
          {
            position: {
              x: 3
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'ResourceId'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/QuickPulseButtonSmallPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 4
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    endTime: null
                    createdTime: '2018-05-04T01:20:33.345Z'
                    isInitialTime: true
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/AvailabilityNavButtonPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 5
              y: 0
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    endTime: null
                    createdTime: '2018-05-08T18:47:35.237Z'
                    isInitialTime: true
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
                {
                  name: 'ConfigurationId'
                  value: '78ce933e-e864-4b05-a27b-71fd55a6afad'
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/AppMapButtonPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 0
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Usage'
                    title: ''
                    subtitle: ''
                  }
                }
              }
            }
          }
          {
            position: {
              x: 3
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    endTime: null
                    createdTime: '2018-05-04T01:22:35.782Z'
                    isInitialTime: true
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/UsageUsersOverviewPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          {
            position: {
              x: 4
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Reliability'
                    title: ''
                    subtitle: ''
                  }
                }
              }
            }
          }
          {
            position: {
              x: 7
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ResourceId'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                }
                {
                  name: 'DataModel'
                  value: {
                    version: '1.0.0'
                    timeContext: {
                      durationMs: 86400000
                      createdTime: '2018-05-04T23:42:40.072Z'
                      isInitialTime: false
                      grain: 1
                      useDashboardTimeRange: false
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'ConfigurationId'
                  value: '8a02f7bf-ac0f-40e1-afe9-f0e72cfee77f'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/CuratedBladeFailuresPinnedPart'
              isAdapter: true
              asset: {
                idInputName: 'ResourceId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'failures'
            }
          }
          {
            position: {
              x: 8
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Responsiveness\r\n'
                    title: ''
                    subtitle: ''
                  }
                }
              }
            }
          }
          {
            position: {
              x: 11
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ResourceId'
                  value: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                }
                {
                  name: 'DataModel'
                  value: {
                    version: '1.0.0'
                    timeContext: {
                      durationMs: 86400000
                      createdTime: '2018-05-04T23:43:37.804Z'
                      isInitialTime: false
                      grain: 1
                      useDashboardTimeRange: false
                    }
                  }
                  isOptional: true
                }
                {
                  name: 'ConfigurationId'
                  value: '2a8ede4f-2bee-4b9c-aed9-2db0e8a01865'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/CuratedBladePerformancePinnedPart'
              isAdapter: true
              asset: {
                idInputName: 'ResourceId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'performance'
            }
          }
          {
            position: {
              x: 12
              y: 1
              colSpan: 3
              rowSpan: 1
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '# Browser'
                    title: ''
                    subtitle: ''
                  }
                }
              }
            }
          }
          {
            position: {
              x: 15
              y: 1
              colSpan: 1
              rowSpan: 1
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'MetricsExplorerJsonDefinitionId'
                  value: 'BrowserPerformanceTimelineMetrics'
                }
                {
                  name: 'TimeContext'
                  value: {
                    durationMs: 86400000
                    createdTime: '2018-05-08T12:16:27.534Z'
                    isInitialTime: false
                    grain: 1
                    useDashboardTimeRange: false
                  }
                }
                {
                  name: 'CurrentFilter'
                  value: {
                    eventTypes: [
                      4
                      1
                      3
                      5
                      2
                      6
                      13
                    ]
                    typeFacets: {}
                    isPermissive: false
                  }
                }
                {
                  name: 'id'
                  value: {
                    Name: app_insights!.outputs.name
                    SubscriptionId: subscription().subscriptionId
                    ResourceGroup: resourceGroup().name
                  }
                }
                {
                  name: 'Version'
                  value: '1.0'
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/AppInsightsExtension/PartType/MetricsExplorerBladePinnedPart'
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
              defaultMenuItemId: 'browser'
            }
          }
          {
            position: {
              x: 0
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'sessions/count'
                          aggregationType: 5
                          namespace: 'microsoft.insights/components/kusto'
                          metricVisualization: {
                            displayName: 'Sessions'
                            color: '#47BDF5'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'users/count'
                          aggregationType: 5
                          namespace: 'microsoft.insights/components/kusto'
                          metricVisualization: {
                            displayName: 'Users'
                            color: '#7E58FF'
                          }
                        }
                      ]
                      title: 'Unique sessions and users'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                            menuid: 'segmentationUsers'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 4
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'requests/failed'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Failed requests'
                            color: '#EC008C'
                          }
                        }
                      ]
                      title: 'Failed requests'
                      visualization: {
                        chartType: 3
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                            menuid: 'failures'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 8
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'requests/duration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Server response time'
                            color: '#00BCF2'
                          }
                        }
                      ]
                      title: 'Server response time'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                            menuid: 'performance'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 12
              y: 2
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'browserTimings/networkDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Page load network connect time'
                            color: '#7E58FF'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'browserTimings/processingDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Client processing time'
                            color: '#44F1C8'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'browserTimings/sendDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Send request time'
                            color: '#EB9371'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'browserTimings/receiveDuration'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Receiving response time'
                            color: '#0672F1'
                          }
                        }
                      ]
                      title: 'Average page load time breakdown'
                      visualization: {
                        chartType: 3
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 0
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'availabilityResults/availabilityPercentage'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Availability'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Average availability'
                      visualization: {
                        chartType: 3
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                      openBladeOnClick: {
                        openBlade: true
                        destinationBlade: {
                          extensionName: 'HubsExtension'
                          bladeName: 'ResourceMenuBlade'
                          parameters: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                            menuid: 'availability'
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 4
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'exceptions/server'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Server exceptions'
                            color: '#47BDF5'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'dependencies/failed'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Dependency failures'
                            color: '#7E58FF'
                          }
                        }
                      ]
                      title: 'Server exceptions and Dependency failures'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 8
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'performanceCounters/processorCpuPercentage'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Processor time'
                            color: '#47BDF5'
                          }
                        }
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'performanceCounters/processCpuPercentage'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Process CPU'
                            color: '#7E58FF'
                          }
                        }
                      ]
                      title: 'Average processor and process CPU utilization'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 12
              y: 5
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'exceptions/browser'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Browser exceptions'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Browser exceptions'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 0
              y: 8
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'availabilityResults/count'
                          aggregationType: 7
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Availability test results count'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Availability test results count'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 4
              y: 8
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'performanceCounters/processIOBytesPerSecond'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Process IO rate'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Average process I/O rate'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
          {
            position: {
              x: 8
              y: 8
              colSpan: 4
              rowSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  value: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${app_insights!.outputs.name}'
                          }
                          name: 'performanceCounters/memoryAvailableBytes'
                          aggregationType: 4
                          namespace: 'microsoft.insights/components'
                          metricVisualization: {
                            displayName: 'Available memory'
                            color: '#47BDF5'
                          }
                        }
                      ]
                      title: 'Average available memory'
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                      }
                    }
                  }
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              #disable-next-line BCP036
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {}
            }
          }
        ]
      }
    ]
  }
}

// ========== Cosmos DB module ========== //
module cosmosDBModule './modules/data/cosmos-db-nosql.bicep' = if (databaseType == 'CosmosDB') {
  name: take('module.cosmos-db-nosql.${solutionName}', 64)
  params: {
    solutionName: solutionSuffix
    location: location
    tags: tags
    // dataPlaneRoleDefinitions: [
    //   {
    //     roleName: 'Cosmos DB SQL Data Contributor'
    //     dataActions: [
    //       'Microsoft.DocumentDB/databaseAccounts/readMetadata'
    //       'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
    //       'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
    //     ]
    //     assignments: [{ principalId: managedIdentityModule.outputs.principalId }]
    //   }
    // ]
  }
}

var postgresResourceName = '${azurePostgresDBAccountName}-postgres'
var postgresDBName = 'postgres'
module postgresDBModule './modules/data/postgresql-flexible-server.bicep' = if (databaseType == 'PostgreSQL') {
  name: take('module.postgre-sql.flexible-server.${solutionName}', 64)
  params: {
    solutionName: solutionSuffix
    location: location
    tags: tags
    version: '16'
    administrators: concat(
      managedIdentityModule.outputs.principalId != ''
        ? [
            {
              objectId: managedIdentityModule.outputs.principalId
              principalName: managedIdentityModule.outputs.name
              principalType: 'ServicePrincipal'
            }
          ]
        : [],
      !empty(principal.id)
        ? [
            {
              objectId: principal.id
              principalName: principal.name
              principalType: principal.type
            }
          ]
        : []
    )
    configurations: [
      {
        name: 'azure.extensions'
        value: 'vector'
        source: 'user-override'
      }
    ]
  }
}

// Store secrets in a keyvault
module keyvault './modules/security/key-vault.bicep' = {
  name: take('module.key-vault.${solutionName}', 64)
  params: {
    solutionName: solutionSuffix
    location: location
    tags: tags
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    roleAssignments: concat(
      managedIdentityModule.outputs.principalId != ''
        ? [
            {
              principalId: managedIdentityModule.outputs.principalId
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: 'Key Vault Secrets User'
            }
          ]
        : [],
      !empty(principal.id)
        ? [
            {
              principalId: principal.id
              roleDefinitionIdOrName: 'Key Vault Secrets User'
            }
          ]
        : []
    )
    secrets: [
      {
        name: 'FUNCTION-KEY'
        value: clientKey
      }
    ]
  }
}

var defaultOpenAiDeployments = [
  {
    name: azureOpenAIModel
    model: {
      format: 'OpenAI'
      name: azureOpenAIModelName
      version: azureOpenAIModelVersion
    }
    sku: {
      name: 'GlobalStandard'
      capacity: azureOpenAIModelCapacity
    }
  }
  {
    name: azureOpenAIEmbeddingModel
    model: {
      format: 'OpenAI'
      name: azureOpenAIEmbeddingModelName
      version: azureOpenAIEmbeddingModelVersion
    }
    sku: {
      name: 'GlobalStandard'
      capacity: azureOpenAIEmbeddingModelCapacity
    }
  }
]

module openai 'modules/core/ai/cognitiveservices.bicep' = {
  name: azureOpenAIResourceName
  scope: resourceGroup()
  params: {
    name: azureOpenAIResourceName
    location: location
    tags: allTags
    kind: 'OpenAI'
    sku: azureOpenAISkuName
    deployments: defaultOpenAiDeployments
    userAssignedResourceId: managedIdentityModule.outputs.resourceId
    // SFI: Azure_AIServices_AuthN_Disable_Local_Auth - force Entra ID authentication.
    disableLocalAuth: true
    restrictOutboundNetworkAccess: true
    allowedFqdnList: concat(
      [
        '${storageAccountName}.blob.${environment().suffixes.storage}'
        '${storageAccountName}.queue.${environment().suffixes.storage}'
      ],
      databaseType == 'CosmosDB' ? ['${azureAISearchName}.search.windows.net'] : []
    )
    enablePrivateNetworking: enablePrivateNetworking
    enableMonitoring: enableMonitoring
    enableTelemetry: enableTelemetry
    subnetResourceId: enablePrivateNetworking ? virtualNetwork!.outputs.pepsSubnetResourceId : null

    logAnalyticsWorkspaceId: enableMonitoring ? monitoring!.outputs.logAnalyticsWorkspaceId : null

    // align with AVM conventions
    privateDnsZoneResourceId: enablePrivateNetworking ? avmPrivateDnsZones[dnsZoneIndex.openAI]!.outputs.resourceId : ''
    roleAssignments: concat(
      [
        {
          roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services Contributor
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
      ],
      !empty(principal.id)
        ? [
            {
              roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
              principalId: principal.id
            }
            {
              roleDefinitionIdOrName: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' // Cognitive Services Contributor
              principalId: principal.id
            }
          ]
        : []
    )
  }
  dependsOn: enablePrivateNetworking ? avmPrivateDnsZones : []
}

module computerVision 'modules/core/ai/cognitiveservices.bicep' = if (useAdvancedImageProcessing) {
  name: 'computerVision'
  scope: resourceGroup()
  params: {
    name: computerVisionName
    kind: 'ComputerVision'
    location: computerVisionLocation != '' ? computerVisionLocation : 'eastus' // Default to eastus if no location provided
    tags: allTags
    sku: computerVisionSkuName
    // SFI: Azure_ComputerVision_AuthN_Disable_Local_Auth - force Entra ID authentication.
    disableLocalAuth: true
    // SFI: Azure_ComputerVision_DP_Data_Loss_Prevention - inherited via cognitiveservices module default (restrictOutboundNetworkAccess: true).

    enablePrivateNetworking: enablePrivateNetworking
    enableMonitoring: enableMonitoring
    enableTelemetry: enableTelemetry
    subnetResourceId: enablePrivateNetworking ? virtualNetwork!.outputs.pepsSubnetResourceId : null

    logAnalyticsWorkspaceId: enableMonitoring ? monitoring!.outputs.logAnalyticsWorkspaceId : null
    userAssignedResourceId: managedIdentityModule.outputs.resourceId
    privateDnsZoneResourceId: enablePrivateNetworking
      ? avmPrivateDnsZones[dnsZoneIndex.cognitiveServices]!.outputs.resourceId
      : ''
    roleAssignments: concat(
      [
        {
          roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
      ],
      !empty(principal.id)
        ? [
            {
              roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
              principalId: principal.id
            }
          ]
        : []
    )
  }
  dependsOn: enablePrivateNetworking ? avmPrivateDnsZones : []
}

// The Web socket from front end application connects to Speech service over a public internet and it does not work over a Private endpoint.
// So public access is enabled even if AVM WAF is enabled.
var enablePrivateNetworkingSpeech = false
module speechService 'modules/core/ai/cognitiveservices.bicep' = {
  name: speechServiceName
  scope: resourceGroup()
  params: {
    name: speechServiceName
    location: location
    kind: 'SpeechServices'
    sku: 'S0'

    enablePrivateNetworking: enablePrivateNetworkingSpeech
    enableMonitoring: enableMonitoring
    enableTelemetry: enableTelemetry
    subnetResourceId: enablePrivateNetworkingSpeech ? virtualNetwork!.outputs.pepsSubnetResourceId : null

    logAnalyticsWorkspaceId: enableMonitoring ? monitoring!.outputs.logAnalyticsWorkspaceId : null
    // SFI exception: Speech SDK uses key-based websocket authentication from the browser, so local auth must remain enabled.
    // Tracked control: Azure_AIServices_AuthN_Disable_Local_Auth.
    disableLocalAuth: false
    userAssignedResourceId: managedIdentityModule.outputs.resourceId
    privateDnsZoneResourceId: enablePrivateNetworkingSpeech
      ? avmPrivateDnsZones[dnsZoneIndex.cognitiveServices]!.outputs.resourceId
      : ''
    roleAssignments: concat(
      [
        {
          roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
      ],
      !empty(principal.id)
        ? [
            {
              roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
              principalId: principal.id
            }
          ]
        : []
    )
  }
  dependsOn: enablePrivateNetworking ? avmPrivateDnsZones : []
}

resource search 'Microsoft.Search/searchServices@2024-06-01-preview' = if (databaseType == 'CosmosDB') {
  name: azureAISearchName
  location: location
  sku: {
    name: azureSearchSku
  }
}

// Separate module for Search Service to enable managed identity and update other properties, as this reduces deployment time for the search service
module searchUpdate 'br/public:avm/res/search/search-service:0.11.1' = if (databaseType == 'CosmosDB') {
  name: take('avm.res.search.update.${azureAISearchName}', 64)
  params: {
    // Required parameters
    name: azureAISearchName
    location: location
    tags: allTags
    enableTelemetry: enableTelemetry
    sku: azureSearchSku
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    disableLocalAuth: false
    hostingMode: 'default'
    networkRuleSet: {
      bypass: 'AzureServices'
      ipRules: []
    }
    partitionCount: 1
    replicaCount: 1
    semanticSearch: azureSearchUseSemanticSearch ? 'free' : 'disabled'

    // WAF aligned configuration for Monitoring
    diagnosticSettings: enableMonitoring ? [{ workspaceResourceId: monitoring!.outputs.logAnalyticsWorkspaceId }] : []

    // WAF aligned configuration for Private Networking
    publicNetworkAccess: enablePrivateNetworking ? 'Disabled' : 'Enabled'

    privateEndpoints: enablePrivateNetworking
      ? [
          {
            name: 'pep-search-${solutionSuffix}'
            privateDnsZoneGroup: {
              privateDnsZoneGroupConfigs: [
                {
                  name: 'search-dns-zone-group-blob'
                  privateDnsZoneResourceId: avmPrivateDnsZones[dnsZoneIndex.searchService]!.outputs.resourceId
                }
              ]
            }
            subnetResourceId: virtualNetwork!.outputs.pepsSubnetResourceId
            service: 'searchService'
          }
        ]
      : []

    // Configure managed identity: user-assigned for production, system-assigned allowed for local development with integrated vectorization
    managedIdentities: { systemAssigned: true, userAssignedResourceIds: [managedIdentityModule.outputs.resourceId] }
    roleAssignments: concat(
      [
        {
          roleDefinitionIdOrName: '8ebe5a00-799e-43f5-93ac-243d3dce84a7' // Search Index Data Contributor
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' // Search Service Contributor
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: '1407120a-92aa-4202-b7e9-c0e197c71c8f' // Search Index Data Reader
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
      ],
      !empty(principal.id)
        ? [
            {
              roleDefinitionIdOrName: '8ebe5a00-799e-43f5-93ac-243d3dce84a7' // Search Index Data Contributor
              principalId: principal.id
            }
            {
              roleDefinitionIdOrName: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' // Search Service Contributor
              principalId: principal.id
            }
            {
              roleDefinitionIdOrName: '1407120a-92aa-4202-b7e9-c0e197c71c8f' // Search Index Data Reader
              principalId: principal.id
            }
          ]
        : []
    )
  }
  dependsOn: [
    search
  ]
}

// AVM WAF - Server Farm + Web Site conversions
var webServerFarmResourceName = hostingPlanName

module webServerFarm 'br/public:avm/res/web/serverfarm:0.5.0' = {
  name: take('avm.res.web.serverfarm.${webServerFarmResourceName}', 64)
  scope: resourceGroup()
  params: {
    name: webServerFarmResourceName
    tags: allTags
    enableTelemetry: enableTelemetry
    location: location
    reserved: true
    kind: 'linux'
    // WAF aligned configuration for Monitoring
    diagnosticSettings: enableMonitoring ? [{ workspaceResourceId: monitoring!.outputs.logAnalyticsWorkspaceId }] : null
    // WAF aligned configuration for Scalability
    skuName: enableScalability || enableRedundancy ? 'P1v3' : hostingPlanSku
    skuCapacity: enableScalability ? 3 : 2
    // WAF aligned configuration for Redundancy
    zoneRedundant: enableRedundancy ? true : false
  }
}

var postgresDBFqdn = '${postgresResourceName}.postgres.database.azure.com'
// endToEndEncryptionEnabled is only supported on Premium v2/v3 or Isolated v2 App Service Plans.
var appServicePlanIsPremium = enableScalability || enableRedundancy
module web 'modules/app/web.bicep' = {
  name: take('module.web.site.${websiteName}${hostingModel == 'container' ? '-docker' : ''}', 64)
  scope: resourceGroup()
  params: {
    // keep existing params but make them conditional so this single module covers both code and container hosting
    name: hostingModel == 'container' ? '${websiteName}-docker' : websiteName
    location: location
    tags: union(tags, { 'azd-service-name': hostingModel == 'container' ? 'web-docker' : 'web' })
    kind: hostingModel == 'container' ? 'app,linux,container' : 'app,linux'
    serverFarmResourceId: webServerFarm.outputs.resourceId
    // runtime settings apply only for code-hosted apps
    runtimeName: hostingModel == 'code' ? 'python' : null
    runtimeVersion: hostingModel == 'code' ? '3.11' : null
    // docker-specific fields apply only for container-hosted apps
    dockerFullImageName: hostingModel == 'container' ? '${registryName}.azurecr.io/rag-webapp:${appversion}' : null
    useDocker: hostingModel == 'container' ? true : false
    allowedOrigins: []
    appCommandLine: ''
    userAssignedIdentityResourceId: managedIdentityModule.outputs.resourceId
    diagnosticSettings: enableMonitoring ? [{ workspaceResourceId: monitoring!.outputs.logAnalyticsWorkspaceId }] : []
    vnetRouteAllEnabled: enablePrivateNetworking ? true : false
    vnetImagePullEnabled: enablePrivateNetworking ? true : false
    virtualNetworkSubnetId: enablePrivateNetworking ? virtualNetwork!.outputs.webSubnetResourceId : ''
    publicNetworkAccess: 'Enabled' // Always enabling public network access
    e2eEncryptionEnabled: appServicePlanIsPremium
    applicationInsightsName: enableMonitoring ? monitoring!.outputs.applicationInsightsName : ''
    appSettings: union(
      {
        AZURE_BLOB_ACCOUNT_NAME: storageAccountName
        AZURE_BLOB_CONTAINER_NAME: blobContainerName
        AZURE_FORM_RECOGNIZER_ENDPOINT: formrecognizer.outputs.endpoint
        AZURE_COMPUTER_VISION_ENDPOINT: useAdvancedImageProcessing ? computerVision!.outputs.endpoint : ''
        AZURE_COMPUTER_VISION_VECTORIZE_IMAGE_API_VERSION: computerVisionVectorizeImageApiVersion
        AZURE_COMPUTER_VISION_VECTORIZE_IMAGE_MODEL_VERSION: computerVisionVectorizeImageModelVersion
        AZURE_CONTENT_SAFETY_ENDPOINT: contentsafety.outputs.endpoint
        AZURE_KEY_VAULT_ENDPOINT: keyvault.outputs.uri
        AZURE_OPENAI_RESOURCE: azureOpenAIResourceName
        AZURE_OPENAI_MODEL: azureOpenAIModel
        AZURE_OPENAI_MODEL_NAME: azureOpenAIModelName
        AZURE_OPENAI_MODEL_VERSION: azureOpenAIModelVersion
        AZURE_OPENAI_TEMPERATURE: azureOpenAITemperature
        AZURE_OPENAI_TOP_P: azureOpenAITopP
        AZURE_OPENAI_MAX_TOKENS: azureOpenAIMaxTokens
        AZURE_OPENAI_STOP_SEQUENCE: azureOpenAIStopSequence
        AZURE_OPENAI_SYSTEM_MESSAGE: azureOpenAISystemMessage
        AZURE_OPENAI_API_VERSION: azureOpenAIApiVersion
        AZURE_OPENAI_STREAM: azureOpenAIStream
        AZURE_OPENAI_EMBEDDING_MODEL: azureOpenAIEmbeddingModel
        AZURE_OPENAI_EMBEDDING_MODEL_NAME: azureOpenAIEmbeddingModelName
        AZURE_OPENAI_EMBEDDING_MODEL_VERSION: azureOpenAIEmbeddingModelVersion
        AZURE_SPEECH_SERVICE_NAME: speechServiceName
        AZURE_SPEECH_SERVICE_REGION: location
        AZURE_SPEECH_RECOGNIZER_LANGUAGES: recognizedLanguages
        AZURE_SPEECH_REGION_ENDPOINT: speechService.outputs.endpoint
        USE_ADVANCED_IMAGE_PROCESSING: useAdvancedImageProcessing ? 'true' : 'false'
        ADVANCED_IMAGE_PROCESSING_MAX_IMAGES: string(advancedImageProcessingMaxImages)
        ORCHESTRATION_STRATEGY: orchestrationStrategy
        CONVERSATION_FLOW: conversationFlow
        LOGLEVEL: logLevel
        PACKAGE_LOGGING_LEVEL: 'WARNING'
        AZURE_LOGGING_PACKAGES: ''
        DATABASE_TYPE: databaseType
        MANAGED_IDENTITY_CLIENT_ID: managedIdentityModule.outputs.clientId
        MANAGED_IDENTITY_RESOURCE_ID: managedIdentityModule.outputs.resourceId
        AZURE_CLIENT_ID: managedIdentityModule.outputs.clientId // Required so LangChain AzureSearch vector store authenticates with this user-assigned managed identity
        APP_ENV: appEnvironment
        AZURE_SEARCH_DIMENSIONS: azureSearchDimensions
        APPLICATIONINSIGHTS_ENABLED: enableMonitoring ? 'true' : 'false'
      },
      databaseType == 'CosmosDB'
        ? {
            AZURE_COSMOSDB_ACCOUNT_NAME: azureCosmosDBAccountName
            AZURE_COSMOSDB_DATABASE_NAME: cosmosDbName
            AZURE_COSMOSDB_CONVERSATIONS_CONTAINER_NAME: cosmosDbContainerName
            AZURE_COSMOSDB_ENABLE_FEEDBACK: 'true'
            AZURE_SEARCH_USE_SEMANTIC_SEARCH: azureSearchUseSemanticSearch ? 'true' : 'false'
            AZURE_SEARCH_SERVICE: 'https://${azureAISearchName}.search.windows.net'
            AZURE_SEARCH_INDEX: azureSearchIndex
            AZURE_SEARCH_CONVERSATIONS_LOG_INDEX: azureSearchConversationLogIndex
            AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG: azureSearchSemanticSearchConfig
            AZURE_SEARCH_INDEX_IS_PRECHUNKED: azureSearchIndexIsPrechunked
            AZURE_SEARCH_TOP_K: azureSearchTopK
            AZURE_SEARCH_ENABLE_IN_DOMAIN: azureSearchEnableInDomain
            AZURE_SEARCH_FILENAME_COLUMN: azureSearchFilenameColumn
            AZURE_SEARCH_FILTER: azureSearchFilter
            AZURE_SEARCH_FIELDS_ID: azureSearchFieldId
            AZURE_SEARCH_CONTENT_COLUMN: azureSearchContentColumn
            AZURE_SEARCH_CONTENT_VECTOR_COLUMN: azureSearchVectorColumn
            AZURE_SEARCH_TITLE_COLUMN: azureSearchTitleColumn
            AZURE_SEARCH_FIELDS_METADATA: azureSearchFieldsMetadata
            AZURE_SEARCH_SOURCE_COLUMN: azureSearchSourceColumn
            AZURE_SEARCH_TEXT_COLUMN: azureSearchUseIntegratedVectorization ? azureSearchTextColumn : ''
            AZURE_SEARCH_LAYOUT_TEXT_COLUMN: azureSearchUseIntegratedVectorization ? azureSearchLayoutTextColumn : ''
            AZURE_SEARCH_CHUNK_COLUMN: azureSearchChunkColumn
            AZURE_SEARCH_OFFSET_COLUMN: azureSearchOffsetColumn
            AZURE_SEARCH_URL_COLUMN: azureSearchUrlColumn
            AZURE_SEARCH_USE_INTEGRATED_VECTORIZATION: azureSearchUseIntegratedVectorization ? 'true' : 'false'
          }
        : databaseType == 'PostgreSQL'
            ? {
                AZURE_POSTGRESQL_HOST_NAME: postgresDBFqdn
                AZURE_POSTGRESQL_DATABASE_NAME: postgresDBName
                AZURE_POSTGRESQL_USER: managedIdentityModule.outputs.name
              }
            : {}
    )
  }
}

module adminweb 'modules/app/adminweb.bicep' = {
  name: take('module.web.site.${adminWebsiteName}${hostingModel == 'container' ? '-docker' : ''}', 64)
  scope: resourceGroup()
  params: {
    name: hostingModel == 'container' ? '${adminWebsiteName}-docker' : adminWebsiteName
    location: location
    tags: union(tags, { 'azd-service-name': hostingModel == 'container' ? 'adminweb-docker' : 'adminweb' })
    allTags: allTags
    kind: hostingModel == 'container' ? 'app,linux,container' : 'app,linux'
    serverFarmResourceId: webServerFarm.outputs.resourceId
    // runtime settings apply only for code-hosted apps
    runtimeName: hostingModel == 'code' ? 'python' : null
    runtimeVersion: hostingModel == 'code' ? '3.11' : null
    // docker-specific fields apply only for container-hosted apps
    dockerFullImageName: hostingModel == 'container' ? '${registryName}.azurecr.io/rag-adminwebapp:${appversion}' : null
    useDocker: hostingModel == 'container' ? true : false
    userAssignedIdentityResourceId: managedIdentityModule.outputs.resourceId
    e2eEncryptionEnabled: appServicePlanIsPremium
    // App settings
    appSettings: union(
      {
        AZURE_BLOB_ACCOUNT_NAME: storageAccountName
        AZURE_BLOB_CONTAINER_NAME: blobContainerName
        AZURE_FORM_RECOGNIZER_ENDPOINT: formrecognizer.outputs.endpoint
        AZURE_COMPUTER_VISION_ENDPOINT: useAdvancedImageProcessing ? computerVision!.outputs.endpoint : ''
        AZURE_COMPUTER_VISION_VECTORIZE_IMAGE_API_VERSION: computerVisionVectorizeImageApiVersion
        AZURE_COMPUTER_VISION_VECTORIZE_IMAGE_MODEL_VERSION: computerVisionVectorizeImageModelVersion
        AZURE_CONTENT_SAFETY_ENDPOINT: contentsafety.outputs.endpoint
        AZURE_KEY_VAULT_ENDPOINT: keyvault.outputs.uri
        AZURE_OPENAI_RESOURCE: azureOpenAIResourceName
        AZURE_OPENAI_MODEL: azureOpenAIModel
        AZURE_OPENAI_MODEL_NAME: azureOpenAIModelName
        AZURE_OPENAI_MODEL_VERSION: azureOpenAIModelVersion
        AZURE_OPENAI_TEMPERATURE: azureOpenAITemperature
        AZURE_OPENAI_TOP_P: azureOpenAITopP
        AZURE_OPENAI_MAX_TOKENS: azureOpenAIMaxTokens
        AZURE_OPENAI_STOP_SEQUENCE: azureOpenAIStopSequence
        AZURE_OPENAI_SYSTEM_MESSAGE: azureOpenAISystemMessage
        AZURE_OPENAI_API_VERSION: azureOpenAIApiVersion
        AZURE_OPENAI_STREAM: azureOpenAIStream
        AZURE_OPENAI_EMBEDDING_MODEL: azureOpenAIEmbeddingModel
        AZURE_OPENAI_EMBEDDING_MODEL_NAME: azureOpenAIEmbeddingModelName
        AZURE_OPENAI_EMBEDDING_MODEL_VERSION: azureOpenAIEmbeddingModelVersion

        USE_ADVANCED_IMAGE_PROCESSING: useAdvancedImageProcessing ? 'true' : 'false'
        BACKEND_URL: 'https://${hostingModel == 'container' ? '${functionName}-docker' : functionName}.azurewebsites.net'
        DOCUMENT_PROCESSING_QUEUE_NAME: queueName
        FUNCTION_KEY: 'FUNCTION-KEY'
        ORCHESTRATION_STRATEGY: orchestrationStrategy
        CONVERSATION_FLOW: conversationFlow
        LOGLEVEL: logLevel
        PACKAGE_LOGGING_LEVEL: 'WARNING'
        AZURE_LOGGING_PACKAGES: ''
        DATABASE_TYPE: databaseType
        USE_KEY_VAULT: 'true'
        MANAGED_IDENTITY_CLIENT_ID: managedIdentityModule.outputs.clientId
        MANAGED_IDENTITY_RESOURCE_ID: managedIdentityModule.outputs.resourceId
        APP_ENV: appEnvironment
        AZURE_SEARCH_DIMENSIONS: azureSearchDimensions
        APPLICATIONINSIGHTS_ENABLED: enableMonitoring ? 'true' : 'false'
      },
      databaseType == 'CosmosDB'
        ? {
            AZURE_SEARCH_SERVICE: 'https://${azureAISearchName}.search.windows.net'
            AZURE_SEARCH_INDEX: azureSearchIndex
            AZURE_SEARCH_USE_SEMANTIC_SEARCH: azureSearchUseSemanticSearch ? 'true' : 'false'
            AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG: azureSearchSemanticSearchConfig
            AZURE_SEARCH_INDEX_IS_PRECHUNKED: azureSearchIndexIsPrechunked
            AZURE_SEARCH_TOP_K: azureSearchTopK
            AZURE_SEARCH_ENABLE_IN_DOMAIN: azureSearchEnableInDomain
            AZURE_SEARCH_FILENAME_COLUMN: azureSearchFilenameColumn
            AZURE_SEARCH_FILTER: azureSearchFilter
            AZURE_SEARCH_FIELDS_ID: azureSearchFieldId
            AZURE_SEARCH_CONTENT_COLUMN: azureSearchContentColumn
            AZURE_SEARCH_CONTENT_VECTOR_COLUMN: azureSearchVectorColumn
            AZURE_SEARCH_TITLE_COLUMN: azureSearchTitleColumn
            AZURE_SEARCH_FIELDS_METADATA: azureSearchFieldsMetadata
            AZURE_SEARCH_SOURCE_COLUMN: azureSearchSourceColumn
            AZURE_SEARCH_TEXT_COLUMN: azureSearchUseIntegratedVectorization ? azureSearchTextColumn : ''
            AZURE_SEARCH_LAYOUT_TEXT_COLUMN: azureSearchUseIntegratedVectorization ? azureSearchLayoutTextColumn : ''
            AZURE_SEARCH_CHUNK_COLUMN: azureSearchChunkColumn
            AZURE_SEARCH_OFFSET_COLUMN: azureSearchOffsetColumn
            AZURE_SEARCH_URL_COLUMN: azureSearchUrlColumn
            AZURE_SEARCH_DATASOURCE_NAME: azureSearchDatasource
            AZURE_SEARCH_INDEXER_NAME: azureSearchIndexer
            AZURE_SEARCH_USE_INTEGRATED_VECTORIZATION: azureSearchUseIntegratedVectorization ? 'true' : 'false'
          }
        : databaseType == 'PostgreSQL'
            ? {
                AZURE_POSTGRESQL_HOST_NAME: postgresDBFqdn
                AZURE_POSTGRESQL_DATABASE_NAME: postgresDBName
                AZURE_POSTGRESQL_USER: managedIdentityModule.outputs.name
              }
            : {}
    )
    applicationInsightsName: enableMonitoring ? monitoring!.outputs.applicationInsightsName : ''
    // WAF parameters
    diagnosticSettings: enableMonitoring ? [{ workspaceResourceId: monitoring!.outputs.logAnalyticsWorkspaceId }] : []
    vnetImagePullEnabled: enablePrivateNetworking ? true : false
    vnetRouteAllEnabled: enablePrivateNetworking ? true : false
    virtualNetworkSubnetId: enablePrivateNetworking ? virtualNetwork!.outputs.webSubnetResourceId : ''
    publicNetworkAccess: 'Enabled' // Always enabling public network access
  }
}

module function 'modules/app/function.bicep' = {
  name: hostingModel == 'container' ? '${functionName}-docker' : functionName
  scope: resourceGroup()
  params: {
    name: hostingModel == 'container' ? '${functionName}-docker' : functionName
    location: location
    tags: union(tags, { 'azd-service-name': hostingModel == 'container' ? 'function-docker' : 'function' })
    runtimeName: 'python'
    runtimeVersion: '3.11'
    dockerFullImageName: hostingModel == 'container' ? '${registryName}.azurecr.io/rag-backend:${appversion}' : ''
    serverFarmResourceId: webServerFarm.outputs.resourceId
    applicationInsightsName: enableMonitoring ? monitoring!.outputs.applicationInsightsName : ''
    storageAccountName: storage.outputs.name
    userAssignedIdentityResourceId: managedIdentityModule.outputs.resourceId
    userAssignedIdentityClientId: managedIdentityModule.outputs.clientId
    // WAF aligned configurations
    diagnosticSettings: enableMonitoring ? [{ workspaceResourceId: monitoring!.outputs.logAnalyticsWorkspaceId }] : []
    virtualNetworkSubnetId: enablePrivateNetworking ? virtualNetwork!.outputs.webSubnetResourceId : ''
    vnetRouteAllEnabled: enablePrivateNetworking ? true : false
    vnetImagePullEnabled: enablePrivateNetworking ? true : false
    publicNetworkAccess: 'Enabled' // Always enabling public network access
    e2eEncryptionEnabled: appServicePlanIsPremium
    appSettings: union(
      {
        AZURE_BLOB_ACCOUNT_NAME: storageAccountName
        AZURE_BLOB_CONTAINER_NAME: blobContainerName
        AZURE_FORM_RECOGNIZER_ENDPOINT: formrecognizer.outputs.endpoint
        AZURE_COMPUTER_VISION_ENDPOINT: useAdvancedImageProcessing ? computerVision!.outputs.endpoint : ''
        AZURE_COMPUTER_VISION_VECTORIZE_IMAGE_API_VERSION: computerVisionVectorizeImageApiVersion
        AZURE_COMPUTER_VISION_VECTORIZE_IMAGE_MODEL_VERSION: computerVisionVectorizeImageModelVersion
        AZURE_CONTENT_SAFETY_ENDPOINT: contentsafety.outputs.endpoint
        AZURE_KEY_VAULT_ENDPOINT: keyvault.outputs.uri
        AZURE_OPENAI_MODEL: azureOpenAIModel
        AZURE_OPENAI_MODEL_NAME: azureOpenAIModelName
        AZURE_OPENAI_MODEL_VERSION: azureOpenAIModelVersion
        AZURE_OPENAI_EMBEDDING_MODEL: azureOpenAIEmbeddingModel
        AZURE_OPENAI_EMBEDDING_MODEL_NAME: azureOpenAIEmbeddingModelName
        AZURE_OPENAI_EMBEDDING_MODEL_VERSION: azureOpenAIEmbeddingModelVersion
        AZURE_OPENAI_RESOURCE: azureOpenAIResourceName
        AZURE_OPENAI_API_VERSION: azureOpenAIApiVersion

        USE_ADVANCED_IMAGE_PROCESSING: useAdvancedImageProcessing ? 'true' : 'false'
        DOCUMENT_PROCESSING_QUEUE_NAME: queueName
        ORCHESTRATION_STRATEGY: orchestrationStrategy
        LOGLEVEL: logLevel
        PACKAGE_LOGGING_LEVEL: 'WARNING'
        AZURE_LOGGING_PACKAGES: ''
        AZURE_OPENAI_SYSTEM_MESSAGE: azureOpenAISystemMessage
        DATABASE_TYPE: databaseType
        MANAGED_IDENTITY_CLIENT_ID: managedIdentityModule.outputs.clientId
        MANAGED_IDENTITY_RESOURCE_ID: managedIdentityModule.outputs.resourceId
        AZURE_CLIENT_ID: managedIdentityModule.outputs.clientId // Required so LangChain AzureSearch vector store authenticates with this user-assigned managed identity
        APP_ENV: appEnvironment
        BACKEND_URL: backendUrl
        AZURE_SEARCH_DIMENSIONS: azureSearchDimensions
        APPLICATIONINSIGHTS_ENABLED: enableMonitoring ? 'true' : 'false'
      },
      databaseType == 'CosmosDB'
        ? {
            AZURE_SEARCH_INDEX: azureSearchIndex
            AZURE_SEARCH_SERVICE: 'https://${azureAISearchName}.search.windows.net'
            AZURE_SEARCH_DATASOURCE_NAME: azureSearchDatasource
            AZURE_SEARCH_INDEXER_NAME: azureSearchIndexer
            AZURE_SEARCH_USE_INTEGRATED_VECTORIZATION: azureSearchUseIntegratedVectorization ? 'true' : 'false'
            AZURE_SEARCH_FIELDS_ID: azureSearchFieldId
            AZURE_SEARCH_CONTENT_COLUMN: azureSearchContentColumn
            AZURE_SEARCH_CONTENT_VECTOR_COLUMN: azureSearchVectorColumn
            AZURE_SEARCH_TITLE_COLUMN: azureSearchTitleColumn
            AZURE_SEARCH_FIELDS_METADATA: azureSearchFieldsMetadata
            AZURE_SEARCH_SOURCE_COLUMN: azureSearchSourceColumn
            AZURE_SEARCH_TEXT_COLUMN: azureSearchUseIntegratedVectorization ? azureSearchTextColumn : ''
            AZURE_SEARCH_LAYOUT_TEXT_COLUMN: azureSearchUseIntegratedVectorization ? azureSearchLayoutTextColumn : ''
            AZURE_SEARCH_CHUNK_COLUMN: azureSearchChunkColumn
            AZURE_SEARCH_OFFSET_COLUMN: azureSearchOffsetColumn
            AZURE_SEARCH_TOP_K: azureSearchTopK
          }
        : databaseType == 'PostgreSQL'
            ? {
                AZURE_POSTGRESQL_HOST_NAME: postgresDBFqdn
                AZURE_POSTGRESQL_DATABASE_NAME: postgresDBName
                AZURE_POSTGRESQL_USER: managedIdentityModule.outputs.name
              }
            : {}
    )
  }
}

// Update your formrecognizer module
module formrecognizer 'modules/core/ai/cognitiveservices.bicep' = {
  name: formRecognizerName
  scope: resourceGroup()
  params: {
    name: formRecognizerName
    location: location
    tags: allTags
    kind: 'FormRecognizer'
    // SFI: Azure_AIServices_AuthN_Disable_Local_Auth - force Entra ID authentication.
    disableLocalAuth: true

    enablePrivateNetworking: enablePrivateNetworking
    enableMonitoring: enableMonitoring
    enableTelemetry: enableTelemetry
    subnetResourceId: enablePrivateNetworking ? virtualNetwork!.outputs.pepsSubnetResourceId : null

    logAnalyticsWorkspaceId: enableMonitoring ? monitoring!.outputs.logAnalyticsWorkspaceId : null
    userAssignedResourceId: managedIdentityModule.outputs.resourceId
    restrictOutboundNetworkAccess: true
    allowedFqdnList: [
      '${storageAccountName}.blob.${environment().suffixes.storage}'
      '${storageAccountName}.queue.${environment().suffixes.storage}'
    ]
    privateDnsZoneResourceId: enablePrivateNetworking
      ? avmPrivateDnsZones[dnsZoneIndex.cognitiveServices]!.outputs.resourceId
      : ''
    enableSystemAssigned: true
    roleAssignments: concat(
      [
        {
          roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
      ],
      !empty(principal.id)
        ? [
            {
              roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
              principalId: principal.id
            }
          ]
        : []
    )
  }
  dependsOn: enablePrivateNetworking ? avmPrivateDnsZones : []
}

module contentsafety 'modules/core/ai/cognitiveservices.bicep' = {
  name: contentSafetyName
  scope: resourceGroup()
  params: {
    name: contentSafetyName
    location: location
    tags: allTags
    kind: 'ContentSafety'
    // SFI: Azure_AIServices_AuthN_Disable_Local_Auth - force Entra ID authentication.
    disableLocalAuth: true

    enablePrivateNetworking: enablePrivateNetworking
    enableMonitoring: enableMonitoring
    enableTelemetry: enableTelemetry
    subnetResourceId: enablePrivateNetworking ? virtualNetwork!.outputs.pepsSubnetResourceId : null

    logAnalyticsWorkspaceId: enableMonitoring ? monitoring!.outputs.logAnalyticsWorkspaceId : null
    userAssignedResourceId: managedIdentityModule.outputs.resourceId
    privateDnsZoneResourceId: enablePrivateNetworking
      ? avmPrivateDnsZones[dnsZoneIndex.cognitiveServices]!.outputs.resourceId
      : ''
    roleAssignments: concat(
      [
        {
          roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
          principalId: managedIdentityModule.outputs.principalId
          principalType: 'ServicePrincipal'
        }
      ],
      !empty(principal.id)
        ? [
            {
              roleDefinitionIdOrName: 'a97b65f3-24c7-4388-baec-2e87135dc908' //Cognitive Services User
              principalId: principal.id
            }
          ]
        : []
    )
  }
  dependsOn: enablePrivateNetworking ? avmPrivateDnsZones : []
}

// If advanced image processing is used, storage account already should be publicly accessible.
// Computer Vision requires files to be publicly accessible as per the official docsumentation: https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/how-to/blob-storage-search
var enablePrivateEndpointsStorage = enablePrivateNetworking && !useAdvancedImageProcessing
module storage './modules/storage/storage-account/storage-account.bicep' = {
  name: take('avm.res.storage.storage-account.${storageAccountName}', 64)
  params: {
    name: storageAccountName
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    supportsHttpsTrafficOnly: true
    // SFI: Azure_Storage_DP_Enable_Infrastructure_Encryption - enforce a second layer of encryption at rest.
    requireInfrastructureEncryption: true
    accessTier: 'Hot'
    skuName: 'Standard_GRS'
    kind: 'StorageV2'
    blobServices: {
      containers: [
        {
          name: blobContainerName
          publicAccess: 'None'
        }
        {
          name: 'config'
          publicAccess: 'None'
        }
      ]
    }
    queueServices: {
      queues: [
        {
          name: 'doc-processing'
        }
        {
          name: 'doc-processing-poison'
        }
      ]
    }
    // Use only user-assigned identities
    managedIdentities: { systemAssigned: false, userAssignedResourceIds: [] }
    roleAssignments: [
      {
        principalId: managedIdentityModule.outputs.principalId
        roleDefinitionIdOrName: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
        principalType: 'ServicePrincipal'
      }
      {
        principalId: managedIdentityModule.outputs.principalId
        roleDefinitionIdOrName: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' // Storage Queue Data Contributor
        principalType: 'ServicePrincipal'
      }
      {
        principalId: managedIdentityModule.outputs.principalId
        roleDefinitionIdOrName: 'Storage File Data Privileged Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
    allowSharedKeyAccess: true
    publicNetworkAccess: enablePrivateEndpointsStorage ? 'Disabled' : 'Enabled'
    networkAcls: { bypass: 'AzureServices', defaultAction: enablePrivateEndpointsStorage ? 'Deny' : 'Allow' }
    privateEndpoints: enablePrivateEndpointsStorage
      ? [
          {
            name: 'pep-blob-${solutionSuffix}'
            privateDnsZoneGroup: {
              privateDnsZoneGroupConfigs: [
                {
                  name: 'storage-dns-zone-group-blob'
                  privateDnsZoneResourceId: avmPrivateDnsZones[dnsZoneIndex.storageBlob]!.outputs.resourceId
                }
              ]
            }
            subnetResourceId: virtualNetwork!.outputs.pepsSubnetResourceId
            service: 'blob'
          }
          {
            name: 'pep-queue-${solutionSuffix}'
            privateDnsZoneGroup: {
              privateDnsZoneGroupConfigs: [
                {
                  name: 'storage-dns-zone-group-queue'
                  privateDnsZoneResourceId: avmPrivateDnsZones[dnsZoneIndex.storageQueue]!.outputs.resourceId
                }
              ]
            }
            subnetResourceId: virtualNetwork!.outputs.pepsSubnetResourceId
            service: 'queue'
          }
          {
            name: 'pep-file-${solutionSuffix}'
            privateDnsZoneGroup: {
              privateDnsZoneGroupConfigs: [
                {
                  name: 'storage-dns-zone-group-file'
                  privateDnsZoneResourceId: avmPrivateDnsZones[dnsZoneIndex.storageFile]!.outputs.resourceId
                }
              ]
            }
            subnetResourceId: virtualNetwork!.outputs.pepsSubnetResourceId
            service: 'file'
          }
        ]
      : []
  }
}

module workbook 'modules/app/workbook.bicep' = if (enableMonitoring) {
  name: 'workbook'
  scope: resourceGroup()
  params: {
    workbookDisplayName: workbookDisplayName
    location: location
    hostingPlanName: webServerFarm.outputs.name
    functionName: function.outputs.functionName
    websiteName: web.outputs.FRONTEND_API_NAME
    adminWebsiteName: adminweb.outputs.WEBSITE_ADMIN_NAME
    eventGridSystemTopicName: avmEventGridSystemTopic!.outputs.name
    logAnalyticsResourceId: monitoring!.outputs.logAnalyticsWorkspaceId
    azureOpenAIResourceName: openai.outputs.name
    azureAISearchName: databaseType == 'CosmosDB' ? search.name : ''
    storageAccountName: storage.outputs.name
  }
}

module avmEventGridSystemTopic 'br/public:avm/res/event-grid/system-topic:0.6.3' = {
  name: take('avm.res.event-grid.system-topic.${eventGridSystemTopicName}', 64)
  params: {
    name: eventGridSystemTopicName
    source: storage.outputs.resourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
    location: location
    tags: allTags
    diagnosticSettings: enableMonitoring
      ? [
          {
            name: 'diagnosticSettings'
            workspaceResourceId: monitoring!.outputs.logAnalyticsWorkspaceId
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
          }
        ]
      : []
    eventSubscriptions: [
      {
        name: 'evts-${solutionSuffix}'
        destination: {
          endpointType: 'StorageQueue'
          properties: {
            queueName: queueName
            resourceId: storage.outputs.resourceId
          }
        }
        eventDeliverySchema: 'EventGridSchema'
        filter: {
          includedEventTypes: [
            'Microsoft.Storage.BlobCreated'
            'Microsoft.Storage.BlobDeleted'
          ]
          enableAdvancedFilteringOnArrays: true
          subjectBeginsWith: '/blobServices/default/containers/${blobContainerName}/blobs/'
        }
        retryPolicy: {
          maxDeliveryAttempts: 30
          eventTimeToLiveInMinutes: 1440
        }
        expirationTimeUtc: '2099-01-01T11:00:21.715Z'
      }
    ]
    // Use only user-assigned identity
    managedIdentities: { systemAssigned: false, userAssignedResourceIds: [managedIdentityModule.outputs.resourceId] }
    enableTelemetry: enableTelemetry
  }
}

var systemAssignedRoleAssignments = union(
  databaseType == 'CosmosDB'
    ? [
        {
          principalId: searchUpdate.?outputs.systemAssignedMIPrincipalId
          resourceId: storage.outputs.resourceId
          roleName: 'Storage Blob Data Contributor'
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
          principalType: 'ServicePrincipal'
        }
        {
          principalId: searchUpdate.?outputs.systemAssignedMIPrincipalId
          resourceId: openai.outputs.resourceId
          roleName: 'Cognitive Services User'
          roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
          principalType: 'ServicePrincipal'
        }
        {
          principalId: searchUpdate.?outputs.systemAssignedMIPrincipalId
          resourceId: openai.outputs.resourceId
          roleName: 'Cognitive Services OpenAI User'
          roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
          principalType: 'ServicePrincipal'
        }
      ]
    : [],
  [
    {
      principalId: formrecognizer.outputs.systemAssignedMIPrincipalId
      resourceId: storage.outputs.resourceId
      roleName: 'Storage Blob Data Contributor'
      roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
      principalType: 'ServicePrincipal'
    }
  ]
)

@description('Role assignments applied to the system-assigned identity via AVM module. Objects can include: roleDefinitionId (req), roleName, principalType, resourceId.')
module systemAssignedIdentityRoleAssignments './modules/app/roleassignments.bicep' = {
  name: take('module.resource-role-assignment.system-assigned', 64)
  params: {
    roleAssignments: systemAssignedRoleAssignments
  }
}

var azureOpenAIModelInfo = string({
  model: azureOpenAIModel
  model_name: azureOpenAIModelName
  model_version: azureOpenAIModelVersion
})

var azureOpenAIEmbeddingModelInfo = string({
  model: azureOpenAIEmbeddingModel
  model_name: azureOpenAIEmbeddingModelName
  model_version: azureOpenAIEmbeddingModelVersion
})

var azureCosmosDBInfo = string({
  account_name: databaseType == 'CosmosDB' ? azureCosmosDBAccountName : ''
  database_name: databaseType == 'CosmosDB' ? cosmosDbName : ''
  conversations_container_name: databaseType == 'CosmosDB' ? cosmosDbContainerName : ''
})

var azurePostgresDBInfo = string({
  host_name: databaseType == 'PostgreSQL' ? postgresDBModule!.outputs.fqdn : ''
  database_name: databaseType == 'PostgreSQL' ? postgresDBName : ''
  user: ''
})

var azureFormRecognizerInfo = string({
  endpoint: formrecognizer.outputs.endpoint
})

var azureBlobStorageInfo = string({
  container_name: blobContainerName
  account_name: storageAccountName
})

var azureSpeechServiceInfo = string({
  service_name: speechServiceName
  service_region: location
  recognizer_languages: recognizedLanguages
})

var azureSearchServiceInfo = databaseType == 'CosmosDB'
  ? string({
      service_name: azureAISearchName
      service: searchUpdate!.outputs.endpoint
      use_semantic_search: azureSearchUseSemanticSearch
      semantic_search_config: azureSearchSemanticSearchConfig
      index_is_prechunked: azureSearchIndexIsPrechunked
      top_k: azureSearchTopK
      enable_in_domain: azureSearchEnableInDomain
      content_column: azureSearchContentColumn
      content_vector_column: azureSearchVectorColumn
      filename_column: azureSearchFilenameColumn
      filter: azureSearchFilter
      title_column: azureSearchTitleColumn
      fields_metadata: azureSearchFieldsMetadata
      source_column: azureSearchSourceColumn
      text_column: azureSearchTextColumn
      layout_column: azureSearchLayoutTextColumn
      url_column: azureSearchUrlColumn
      use_integrated_vectorization: azureSearchUseIntegratedVectorization
      index: azureSearchIndex
      indexer_name: azureSearchIndexer
      datasource_name: azureSearchDatasource
    })
  : ''

var azureComputerVisionInfo = string({
  service_name: computerVisionName
  endpoint: useAdvancedImageProcessing ? computerVision!.outputs.endpoint : ''
  location: useAdvancedImageProcessing ? computerVision!.outputs.location : ''
  vectorize_image_api_version: computerVisionVectorizeImageApiVersion
  vectorize_image_model_version: computerVisionVectorizeImageModelVersion
})

var azureOpenaiConfigurationInfo = string({
  service_name: speechServiceName
  stream: azureOpenAIStream
  system_message: azureOpenAISystemMessage
  stop_sequence: azureOpenAIStopSequence
  max_tokens: azureOpenAIMaxTokens
  top_p: azureOpenAITopP
  temperature: azureOpenAITemperature
  api_version: azureOpenAIApiVersion
  resource: azureOpenAIResourceName
})

var azureContentSafetyInfo = string({
  endpoint: contentsafety.outputs.endpoint
})

var backendUrl = hostingModel == 'container'
  ? 'https://${functionName}-docker.azurewebsites.net'
  : 'https://${functionName}.azurewebsites.net'

@description('Connection string for the Application Insights instance.')
output APPLICATIONINSIGHTS_CONNECTION_STRING string = enableMonitoring
  ? monitoring!.outputs.applicationInsightsConnectionString
  : ''

@description('App Service hosting model used (code or container).')
output AZURE_APP_SERVICE_HOSTING_MODEL string = hostingModel

@description('Name of the resource group.')
output resourceGroupName string = resourceGroup().name

@description('Application environment (e.g., Prod, Dev).')
output APP_ENV string = appEnvironment

@description('Blob storage info (container and account).')
output AZURE_BLOB_STORAGE_INFO string = azureBlobStorageInfo

@description('Computer Vision service information.')
output AZURE_COMPUTER_VISION_INFO string = azureComputerVisionInfo

@description('Content Safety service endpoint information.')
output AZURE_CONTENT_SAFETY_INFO string = azureContentSafetyInfo

@description('Form Recognizer service endpoint information.')
output AZURE_FORM_RECOGNIZER_INFO string = azureFormRecognizerInfo

@description('Primary deployment location.')
output AZURE_LOCATION string = location

@description('Azure OpenAI model information.')
output AZURE_OPENAI_MODEL_INFO string = azureOpenAIModelInfo

@description('Azure OpenAI configuration details.')
output AZURE_OPENAI_CONFIGURATION_INFO string = azureOpenaiConfigurationInfo

@description('Azure OpenAI embedding model information.')
output AZURE_OPENAI_EMBEDDING_MODEL_INFO string = azureOpenAIEmbeddingModelInfo

@description('Name of the resource group.')
output AZURE_RESOURCE_GROUP string = resourceGroup().name

@description('Azure Cognitive Search service information (if deployed).')
output AZURE_SEARCH_SERVICE_INFO string = azureSearchServiceInfo

@description('Azure Speech service information.')
output AZURE_SPEECH_SERVICE_INFO string = azureSpeechServiceInfo

@description('Azure tenant identifier.')
output AZURE_TENANT_ID string = tenant().tenantId

@description('Name of the document processing queue.')
output DOCUMENT_PROCESSING_QUEUE_NAME string = queueName

@description('Orchestration strategy selected (openai_function, semantic_kernel, etc.).')
output ORCHESTRATION_STRATEGY string = orchestrationStrategy

@description('Backend URL for the function app.')
output BACKEND_URL string = backendUrl

@description('Azure WebJobs Storage connection string for the Functions app.')
output AzureWebJobsStorage string = function.outputs.AzureWebJobsStorage

@description('Frontend web application resource name (for azd deploy).')
output SERVICE_WEB_RESOURCE_NAME string = web.outputs.FRONTEND_API_NAME

@description('Admin web application resource name (for azd deploy).')
output SERVICE_ADMINWEB_RESOURCE_NAME string = adminweb.outputs.WEBSITE_ADMIN_NAME

@description('Function app resource name (for azd deploy).')
output SERVICE_FUNCTION_RESOURCE_NAME string = function.outputs.functionName

@description('Frontend web application URI.')
output FRONTEND_WEBSITE_NAME string = web.outputs.FRONTEND_API_URI

@description('Admin web application URI.')
output ADMIN_WEBSITE_NAME string = adminweb.outputs.WEBSITE_ADMIN_URI

@description('Configured log level for applications.')
output LOGLEVEL string = logLevel

@description('Conversation flow type in use (custom or byod).')
output CONVERSATION_FLOW string = conversationFlow

@description('Whether advanced image processing is enabled.')
output USE_ADVANCED_IMAGE_PROCESSING bool = useAdvancedImageProcessing

@description('Whether Azure Search is using integrated vectorization.')
output AZURE_SEARCH_USE_INTEGRATED_VECTORIZATION bool = azureSearchUseIntegratedVectorization

@description('Maximum number of images sent per advanced image processing request.')
output ADVANCED_IMAGE_PROCESSING_MAX_IMAGES int = advancedImageProcessingMaxImages

@description('Unique token for this solution deployment (short suffix).')
output RESOURCE_TOKEN string = solutionSuffix

@description('Cosmos DB related information (account/database/container).')
output AZURE_COSMOSDB_INFO string = azureCosmosDBInfo

@description('PostgreSQL related information (host/database/user).')
output AZURE_POSTGRESQL_INFO string = azurePostgresDBInfo

@description('Selected database type for this deployment.')
output DATABASE_TYPE string = databaseType

@description('System prompt for OpenAI functions.')
output OPEN_AI_FUNCTIONS_SYSTEM_PROMPT string = openAISystemPrompts.OPEN_AI_FUNCTIONS_SYSTEM_PROMPT

@description('System prompt used by the Semantic Kernel orchestration.')
output SEMANTIC_KERNEL_SYSTEM_PROMPT string = openAISystemPrompts.SEMANTIC_KERNEL_SYSTEM_PROMPT
