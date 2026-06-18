// ============================================================================
// Module: Cosmos DB SQL Role Assignment (data-plane)
// Description: Grants a principal a Cosmos DB SQL data-plane role on a
//              Microsoft.DocumentDB account. Required when local auth is
//              disabled — ARM `Microsoft.Authorization/roleAssignments` does
//              NOT grant data-plane access to Cosmos DB; only
//              `Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments`
//              against a SQL role definition (built-in or custom) does.
// API: Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15
// ============================================================================

@description('The name of the existing Cosmos DB (NoSQL) account.')
param cosmosDbAccountName string

@description('The principal ID (objectId) of the user, group, or service principal to assign the role to.')
param principalId string

@description('The Cosmos DB SQL role definition GUID to assign. Defaults to the built-in "Cosmos DB Built-in Data Contributor" role (00000000-0000-0000-0000-000000000002), which grants read/write/query access to data, including listing conversations from a container.')
param roleDefinitionId string = '00000000-0000-0000-0000-000000000002'

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' existing = {
  name: cosmosDbAccountName
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmos
  name: guid(cosmos.id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    roleDefinitionId: '${cosmos.id}/sqlRoleDefinitions/${roleDefinitionId}'
    scope: cosmos.id
  }
}

output roleAssignmentId string = sqlRoleAssignment.id
