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
      type: 9
      content: {
        version: 'KqlParameterItem/1.0'
        parameters: [
          {
            id: '85b26c76-16ed-439b-a4c7-df38e6ea00d6'
            version: 'KqlParameterItem/1.0'
            name: 'runId'
            label: 'Run ID'
            type: 2
            description: 'Run ID to display'
            isRequired: true
            query: 'PSRule_CL\r\n| summarize Date=format_datetime(max(TimeGenerated), "yyyy-MM-dd HH:mm") by RunId_s\r\n| sort by Date desc'
            typeSettings: {
              additionalResourceOptions: []
            }
            timeContext: {
              durationMs: 2592000000
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            value: 'c442098b2437a6f6f3496768ba2f698790ecab2f'
          }
          {
            id: '71025be9-30c0-45b1-9eac-d87b93f7a99c'
            version: 'KqlParameterItem/1.0'
            name: 'Organization'
            type: 2
            description: 'Azure DevOps Organization(s) to display'
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
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          {
            id: '10f14246-d8dc-4175-a072-308b458c3f89'
            version: 'KqlParameterItem/1.0'
            name: 'Project'
            type: 2
            description: 'Azure DevOps Project to display'
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
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            value: [
              'value::all'
            ]
          }
        ]
        style: 'above'
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
      }
      name: 'parameters - 1'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| where RunId_s == \'{runId}\'\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))    \r\n| summarize\r\n        [\'Total Resources\'] = dcount(TargetName_s),\r\n        [\'Failed Resources\'] = dcountif(TargetName_s, Outcome_s == \'Fail\'),\r\n        [\'Passed Resources\'] = dcountif(TargetName_s, Outcome_s == \'Pass\')\r\n    by Rule=DisplayName_s, tostring([\'Rule Help Url\']), tostring(Severity)\r\n| sort by [\'Failed Resources\'] desc'
        size: 3
        timeContext: {
          durationMs: 2592000000
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
                    {
                      name: 'runId'
                      source: 'parameter'
                      value: 'runId'
                    }
                    {
                      name: 'Project'
                      source: 'parameter'
                      value: 'Project'
                    }
                    {
                      name: 'Organization'
                      source: 'parameter'
                      value: 'Organization'
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
