targetScope = 'resourceGroup'

@description('Workbook name')
param workbook_AzureDevOpsSummaryByRule_Name string = '8a85b913-bfee-455c-a2b7-dd2402e393bb'

@description('Azure DevOps resources by rule workbook template id')
param AzDoResourcesByRuleId string

@description('Log Analytics workspace id')
param logAnalyticsWorkspaceId string

@description('Location for all resources.')
param location string = resourceGroup().location

var workbook = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| where TimeGenerated >= datetime_add(\'day\', -1, now())\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend [\'Resource Id\']=f.id, Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| summarize\r\n        [\'Total Resources\'] = dcount(TargetName_s),\r\n        [\'Failed Resources\'] = dcountif(TargetName_s, Outcome_s == \'Fail\'),\r\n        [\'Passed Resources\'] = dcountif(TargetName_s, Outcome_s == \'Pass\')\r\n    by Rule=DisplayName_s, tostring([\'Rule Help Url\']), tostring(Severity)\r\n| sort by [\'Failed Resources\'] desc'
        size: 3
        timeContext: {
          durationMs: 86400000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        gridSettings: {
          formatters: [
            {
              columnMatch: 'Rule'
              formatter: 7
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                linkIsContextBlade: true
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoResourcesByRuleId
                  typeSource: 'workbook'
                  gallerySource: 'workbook'
                  locationSource: 'default'
                  workbookName: 'Resources by Rule'
                  passSpecificParams: true
                  templateParameters: [
                    {
                      name: 'ruleName'
                      source: 'cell'
                      value: ''
                    }
                  ]
                  viewerMode: false
                }
              }
            }
            {
              columnMatch: 'Rule Help Url'
              formatter: 5
            }
            {
              columnMatch: 'Severity'
              formatter: 18
              formatOptions: {
                linkColumn: 'Rule Help Url'
                linkTarget: 'Url'
                thresholdsOptions: 'icons'
                thresholdsGrid: [
                  {
                    operator: '=='
                    thresholdValue: 'Critical'
                    representation: '4'
                    text: '{0}{1}'
                  }
                  {
                    operator: '=='
                    thresholdValue: 'Severe'
                    representation: '3'
                    text: '{0}{1}'
                  }
                  {
                    operator: '=='
                    thresholdValue: 'Important'
                    representation: '2'
                    text: '{0}{1}'
                  }
                  {
                    operator: '=='
                    thresholdValue: 'Informational'
                    representation: '1'
                    text: '{0}{1}'
                  }
                  {
                    operator: 'Default'
                    thresholdValue: null
                    representation: 'success'
                    text: '{0}{1}'
                  }
                ]
              }
            }
            {
              columnMatch: 'Failed Resources'
              formatter: 18
              formatOptions: {
                thresholdsOptions: 'icons'
                thresholdsGrid: [
                  {
                    operator: '>='
                    thresholdValue: '1'
                    representation: 'failed'
                    text: '{0}{1}'
                  }
                  {
                    operator: 'Default'
                    thresholdValue: null
                    representation: 'success'
                    text: '{0}{1}'
                  }
                ]
              }
            }
          ]
        }
      }
      name: 'rule-hit-per-rule'
    }
  ]
  fallbackResourceIds: [
    logAnalyticsWorkspaceId
  ]
  '$schema': 'https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json'
}

resource workbook_AzureDevOpsSummaryByRule 'microsoft.insights/workbooks@2023-06-01' = {
  name: workbook_AzureDevOpsSummaryByRule_Name
  location: location
  tags: {
    'hidden-title': 'Azure DevOps Summary by Rule'
  }
  kind: 'shared'
  identity: {
    type: 'None'
  }
  properties: {
    displayName: 'Azure DevOps Summary by Rule'
    version: 'Notebook/1.0'
    category: 'workbook'
    sourceId: logAnalyticsWorkspaceId
    serializedData: string(workbook)
  }
}

output id string = workbook_AzureDevOpsSummaryByRule.id
