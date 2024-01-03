targetScope = 'resourceGroup'
param logAnalyticsWorkspace_Name string = 'log-psrule-azdo-prd-weu'
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


resource workspaces_PSRule_CL 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'PSRule_CL'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'PSRule_CL'
      columns: [
        {
          name: 'RuleId_s'
          type: 'string'
        }
        {
          name: 'RuleName_s'
          type: 'string'
        }
        {
          name: 'DisplayName_s'
          type: 'string'
        }
        {
          name: 'TargetName_s'
          type: 'string'
        }
        {
          name: 'TargetType_s'
          type: 'string'
        }
        {
          name: 'Outcome_s'
          type: 'string'
        }
        {
          name: 'Field_s'
          type: 'string'
        }
        {
          name: 'Annotations_s'
          type: 'string'
        }
        {
          name: 'RunId_s'
          type: 'string'
        }
        {
          name: 'CorrelationId'
          type: 'string'
        }
        {
          name: 'Duration_d'
          type: 'real'
        }
        {
          name: 'TimeGenerated'
          type: 'datetime'
        }
      ]
    }
    retentionInDays: 30
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsSharedKey string = logAnalyticsWorkspace.listKeys().primarySharedKey
