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
            query: 'PSRule_CL\r\n| summarize by RuleName_s'
            typeSettings: {
              additionalResourceOptions: [
                'value::all'
              ]
              selectAllValue: 'All Rules'
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          {
            id: '69ed445b-75d8-41bd-bd99-ed5a99a0cc3a'
            version: 'KqlParameterItem/1.0'
            name: 'runId'
            label: 'Run ID'
            type: 2
            description: 'Run ID to display'
            isRequired: true
            query: 'PSRule_CL\r\n| summarize Date=format_datetime(max(TimeGenerated), "yyyy-MM-dd HH:mm") by RunId_s\r\n| sort by Date desc'
            typeSettings: {
              additionalResourceOptions: []
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            value: 'daf923fb2463077368e92134a02eda43787659ec'
          }
          {
            id: '01f572fc-067d-4429-9be7-9299a08122fd'
            version: 'KqlParameterItem/1.0'
            name: 'Organization'
            type: 2
            description: 'Azure DevOps Organization to display'
            isRequired: true
            multiSelect: true
            quote: '\''
            delimiter: ','
            query: 'PSRule_CL\r\n| extend \r\n    f=parse_json(Field_s)\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization\r\n| summarize by tostring(Organization)'
            typeSettings: {
              additionalResourceOptions: [
                'value::all'
              ]
              selectAllValue: 'All Organizations'
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          {
            id: '1f177f23-98c1-4dad-a9b5-5e1f3f7922f7'
            version: 'KqlParameterItem/1.0'
            name: 'Project'
            type: 2
            description: 'Azure DevOps Projects to display'
            isRequired: true
            multiSelect: true
            quote: '\''
            delimiter: ','
            query: 'PSRule_CL\r\n| extend \r\n    f=parse_json(Field_s)\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Project=expandedId.[\'project\']\r\n| summarize by tostring(Project)'
            typeSettings: {
              additionalResourceOptions: [
                'value::all'
              ]
              selectAllValue: 'All Projects'
            }
            timeContext: {
              durationMs: 2592000000
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
        query: 'PSRule_CL\r\n| where RunId_s == \'{runId}\'\r\n| where DisplayName_s in ({ruleName}) or \'All Rules\' in ({ruleName})\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))    \r\n\r\n| extend severity_level = case(\r\n    Severity == "Informational" and Outcome_s == \'Fail\', 1,\r\n    Severity == "Important" and Outcome_s == \'Fail\', 2,\r\n    Severity == "Severe" and Outcome_s == \'Fail\', 3,\r\n    Severity == "Critical" and Outcome_s == \'Fail\', 4,\r\n    0)\r\n| project Organization,Project,[\'Resource Name\']=ResourceName,[\'Resource FQN\']=TargetName_s, [\'Outcome\']=Outcome_s\r\n| sort by Outcome asc'
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
