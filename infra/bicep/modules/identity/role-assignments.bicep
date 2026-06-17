// ============================================================================
// Module: Role Assignments (centralized — all cross-service + data plane RBAC)
// Description: RG-level, cross-service, and data-plane role assignments.
//              One place to audit "who has access to what".
// ============================================================================

@description('The principal ID of the user, group, or service principal to assign the role to.')
param principalId string

@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
@description('The type of principal to assign the role to. Allowed values: Device, ForeignGroup, Group, ServicePrincipal, User.')
param principalType string = 'ServicePrincipal'

@description('The role definition ID of the role to assign. This can be a built-in role or a custom role.')
param roleDefinitionId string


resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
