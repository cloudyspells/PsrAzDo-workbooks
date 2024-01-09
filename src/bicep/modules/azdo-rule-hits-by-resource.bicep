targetScope = 'resourceGroup'

@description('Workbook name')
param workbook_AzureDevOpsRuleHitsByResource_Name string = 'c427ecce-350b-4a2e-b5f9-d4fddbf1acb4'

@description('Log Analytics workspace id')
param logAnalyticsWorkspaceId string

@description('Location for all resources.')
param location string = resourceGroup().location

var workbook = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 9
      content: {
        version: 'KqlParameterItem/1.0'
        parameters: [
          {
            id: '7c152b4a-88d4-4803-b44f-e555182054d0'
            version: 'KqlParameterItem/1.0'
            name: 'resourceName'
            label: 'Resource Name'
            type: 2
            description: 'Name of the resource of the rule hits'
            isRequired: true
            multiSelect: true
            quote: '\''
            delimiter: ','
            query: 'PSRule_CL\r\n| summarize by TargetName_s'
            typeSettings: {
              additionalResourceOptions: [
                'value::all'
              ]
              selectAllValue: 'All Resources'
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            value: [
              'Azure.DevOps.Repo/cloudyspells.psrule-scan-ado.demo-scan-ado'
            ]
          }
          {
            id: '496436b2-fb7b-4288-887e-0ea21dbd8134'
            version: 'KqlParameterItem/1.0'
            name: 'runId'
            label: 'Run ID'
            type: 2
            description: 'Select results from this run'
            isRequired: true
            query: 'PSRule_CL\r\n| summarize Date=format_datetime(max(TimeGenerated),\'yyyy-MM-dd HH:mm\') by RunId_s\r\n| sort by Date desc'
            typeSettings: {
              additionalResourceOptions: []
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            value: 'psrule-scan-ado/285'
          }
        ]
        style: 'above'
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
      }
      conditionalVisibilities: [
        {
          parameterName: 'runId'
          comparison: 'isEqualTo'
        }
        {
          parameterName: 'resourceName'
          comparison: 'isEqualTo'
        }
      ]
      name: 'parameters - 1'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: '\r\nPSRule_CL\r\n| where (\'All Resources\' in ({resourceName}) or TargetName_s in ({resourceName}))\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend [\'Resource Id\']=f.id, Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend severity_level = case(\r\n    Severity == "Informational" and Outcome_s == \'Fail\', 1,\r\n    Severity == "Important" and Outcome_s == \'Fail\', 2,\r\n    Severity == "Severe" and Outcome_s == \'Fail\', 3,\r\n    Severity == "Critical" and Outcome_s == \'Fail\', 4,\r\n    0)\r\n| project RunId_s,[\'Resource FQN\']=TargetName_s,Rule=DisplayName_s,Outcome=Outcome_s,Severity,[\'Rule Help Url\'],severity_level,TimeGenerated\r\n| extend Findings = case(\r\n    severity_level == 1, "Informational",\r\n    severity_level == 2, "Important",\r\n    severity_level == 3, "Severe",\r\n    severity_level == 4, "Critical",\r\n    severity_level == 0, "Passed",\r\n    "Not found")\r\n| summarize [\'Hit count\']=count(), [\'Audit Date\']=format_datetime(max(TimeGenerated), "yyyy-MM-dd HH:mm") by Findings, RunId_s\r\n| sort by [\'Audit Date\'] asc\r\n'
        size: 1
        aggregation: 5
        timeContext: {
          durationMs: 2592000000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        visualization: 'linechart'
        chartSettings: {
          xAxis: 'Audit Date'
          group: 'Findings'
          createOtherGroup: null
          showLegend: true
          showDataPoints: true
        }
      }
      name: 'query - 2'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: '\r\nPSRule_CL\r\n| where RunId_s == \'{runId}\'\r\n| where (\'All Resources\' in ({resourceName}) or TargetName_s in ({resourceName}))\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend [\'Resource Id\']=f.id, Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend severity_level = case(\r\n    Severity == "Informational" and Outcome_s == \'Fail\', 1,\r\n    Severity == "Important" and Outcome_s == \'Fail\', 2,\r\n    Severity == "Severe" and Outcome_s == \'Fail\', 3,\r\n    Severity == "Critical" and Outcome_s == \'Fail\', 4,\r\n    0)\r\n| project [\'Resource FQN\']=TargetName_s,Rule=DisplayName_s,Outcome=Outcome_s,Severity,[\'Rule Help Url\'],severity_level\r\n| sort by severity_level desc'
        size: 0
        timeContext: {
          durationMs: 2592000000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        gridSettings: {
          formatters: [
            {
              columnMatch: 'Resource FQN'
              formatter: 5
            }
            {
              columnMatch: 'Rule'
              formatter: 18
              formatOptions: {
                linkColumn: 'Rule Help Url'
                linkTarget: 'Url'
                thresholdsOptions: 'icons'
                thresholdsGrid: [
                  {
                    operator: 'Default'
                    thresholdValue: null
                    representation: 'Hyperlink'
                    text: '{0}{1}'
                  }
                ]
                compositeBarSettings: {
                  labelText: ''
                  columnSettings: []
                }
              }
            }
            {
              columnMatch: 'Outcome'
              formatter: 18
              formatOptions: {
                thresholdsOptions: 'icons'
                thresholdsGrid: [
                  {
                    operator: '=='
                    thresholdValue: 'Fail'
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
              columnMatch: 'Rule Help Url'
              formatter: 5
              formatOptions: {
                linkTarget: 'Url'
              }
            }
            {
              columnMatch: 'severity_level'
              formatter: 5
            }
          ]
        }
      }
      name: 'all-rule-hits'
    }
  ]
  fallbackResourceIds: [
    logAnalyticsWorkspaceId
  ]
  '$schema': 'https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json'
}

resource workbook_AzureDevOpsRuleHitsByResource 'microsoft.insights/workbooks@2023-06-01' = {
  name: workbook_AzureDevOpsRuleHitsByResource_Name
  location: location
  tags: {
    'hidden-title': 'Azure DevOps Rule Hits by Resource'
  }
  kind: 'shared'
  identity: {
    type: 'None'
  }
  properties: {
    displayName: 'Azure DevOps Rule Hits by Resource'
    version: 'Notebook/1.0'
    category: 'workbook'
    sourceId: logAnalyticsWorkspaceId
    serializedData: string(workbook)
  }
}

output id string = workbook_AzureDevOpsRuleHitsByResource.id
