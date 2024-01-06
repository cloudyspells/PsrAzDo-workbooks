targetScope = 'resourceGroup'

@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the workbook.')
param workbook_AzureDevOpsResourceByRule_Name string = 'd480c68c-7585-4395-ab9a-39f1e666397b'

var workbook = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 9
      content: {
        version: 'KqlParameterItem/1.0'
        parameters: [
          {
            id: '3f1e834c-9a51-41b3-aa49-88a8834e7aba'
            version: 'KqlParameterItem/1.0'
            name: 'ruleName'
            label: 'Rule Name'
            type: 2
            isRequired: true
            multiSelect: true
            quote: '\''
            delimiter: ','
            query: 'PSRule_CL\r\n| summarize by DisplayName_s'
            typeSettings: {
              additionalResourceOptions: [
                'value::all'
              ]
              selectAllValue: 'All Rules'
              showDefault: false
            }
            timeContext: {
              durationMs: 86400000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
        ]
        style: 'above'
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
      }
      name: 'parameters - 0'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| where DisplayName_s in ({ruleName}) or \'All Rules\' in ({ruleName})\r\n| where TimeGenerated >= datetime_add(\'day\', -1, now())\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend [\'Resource Id\']=f.id, Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend severity_level = case(\r\n    Severity == "Informational" and Outcome_s == \'Fail\', 1,\r\n    Severity == "Important" and Outcome_s == \'Fail\', 2,\r\n    Severity == "Severe" and Outcome_s == \'Fail\', 3,\r\n    Severity == "Critical" and Outcome_s == \'Fail\', 4,\r\n    0)\r\n| project [\'Resource FQN\']=TargetName_s, [\'Outcome\']=Outcome_s\r\n| sort by Outcome asc'
        size: 0
        timeContext: {
          durationMs: 86400000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        gridSettings: {
          formatters: [
            {
              columnMatch: 'Resource FQN'
              formatter: 0
              formatOptions: {
                customColumnWidthSetting: '100ch'
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
                    operator: '=='
                    thresholdValue: 'Pass'
                    representation: 'success'
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
      name: 'resources-per-rule'
    }
  ]
  fallbackResourceIds: [
    logAnalyticsWorkspaceId
  ]
  '$schema': 'https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json'
}

resource workbook_AzureDevOpsResourceByRule 'microsoft.insights/workbooks@2023-06-01' = {
  name: workbook_AzureDevOpsResourceByRule_Name
  location: location
  tags: {
    'hidden-title': 'Azure DevOps Resources by Rule'
  }
  kind: 'shared'
  identity: {
    type: 'None'
  }
  properties: {
    displayName: 'Azure DevOps Resources by Rule'
    version: 'Notebook/1.0'
    category: 'workbook'
    sourceId: logAnalyticsWorkspaceId
    serializedData: string(workbook)
  }
}

output id string = workbook_AzureDevOpsResourceByRule.id
