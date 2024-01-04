targetScope = 'resourceGroup'

@description('Azure DevOps Organization')
param azDoOrganization string

@description('Azure DevOps Personal Access Token')
@secure()
param azDoPAT string

@description('Log Analytics Workspace Name')
param logAnalyticsWorkspace_Name string = 'log-psrule-azdo-prd-weu'

@description('Key Vault Name')
param keyVault_Name string = 'kv-psrule-azdo-prd-weu'

@description('Location for all resources')
param location string = 'westeurope'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspace_Name
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: false
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVault_Name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
  }
}

resource secretWorkspaceId 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'logAnalyticsWorkspaceId'
  properties: {
    value: logAnalyticsWorkspace.properties.customerId
  }
}

resource secretWorkspaceSharedKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'logAnalyticsSharedKey'
  properties: {
    value: logAnalyticsWorkspace.listKeys().primarySharedKey
  }
}

resource secretAzDoPAT 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZDO-PAT'
  properties: {
    value: azDoPAT
  }
}

resource secretAzDoOrganization 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZDO-ORGANIZATION'
  properties: {
    value: azDoOrganization
  }
}

module workbookAzDoMain 'modules/azdo-main.bicep' = {
  name: 'workbookAzDoMain'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    location: location
    AzDoResourceStateId: workbookAzDoResourceState.outputs.id
    AzDoRuleSummaryId: workbookAzDoSummaryByRule.outputs.id
  }
}

module workbookAzDoResourceByRule 'modules/azdo-resources-by-rule.bicep' = {
  name: 'workbookAzDoResourceByRule'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    location: location
  }
}

module workbookAzDoRuleHitsByResource 'modules/azdo-rule-hits-by-resource.bicep' = {
  name: 'workbookAzDoRuleHitsByResource'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    location: location
  }
}

module workbookAzDoSummaryByRule 'modules/azdo-summary-by-rule.bicep' = {
  name: 'workbookAzDoSummaryByRule'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    location: location
    AzDoResourcesByRuleId: workbookAzDoResourceByRule.outputs.id
  }
}

module workbookAzDoResourceState 'modules/azdo-resource-state.bicep' = {
  name: 'workbookAzDoResourceState'
  params: {
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    location: location
    AzDoRuleHitsByResourceId: workbookAzDoRuleHitsByResource.outputs.id
  }
}

resource workspaces_AzureDevOpsAuditing 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'AzureDevOpsAuditing'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AzureDevOpsAuditing'
    }
    retentionInDays: 30
  }
}
