targetScope = 'resourceGroup'

@description('Azure DevOps Resource State workbook template id')
param AzDoResourceStateId string

@description('Azure DevOps Rule Summary workbook template id')
param AzDoRuleSummaryId string

@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the workbook.')
param workbook_AzureDevOpsMain_Name string = '3e13ee7a-3663-4f94-87fc-a10ea6956405'

var workbook = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 1
      content: {
        json: '## Azure DevOps Best Practice Audit\n---\n\nThis workbook contains links to explore the various workbooks built\nfor [PSRule.Rules.AzureDevOps](https://github.com/cloudyspells/PSRule.Rules.AzureDevOps).\n\nCurrently workbooks for exploring results either by rule or by resource are available.'
      }
      name: 'text - 2'
    }
    {
      type: 9
      content: {
        version: 'KqlParameterItem/1.0'
        parameters: [
          {
            id: 'a92d2f52-68e7-4732-b57c-13a91c0f4286'
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
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
          {
            id: 'be06be92-e842-41e9-a9d7-b70fa3e8cf07'
            version: 'KqlParameterItem/1.0'
            name: 'Project'
            type: 2
            description: 'Azure DevOps Project to display'
            isRequired: true
            multiSelect: true
            quote: '\''
            delimiter: ','
            query: 'PSRule_CL\r\n| extend\r\n    f=parse_json(Field_s)\r\n| extend\r\n    expandedId=parse_json(tostring(f.id))\r\n| extend\r\n    [\'Project\']=expandedId.[\'project\']\r\n| summarize by tostring(Project)'
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
            value: [
              'value::all'
            ]
          }
        ]
        style: 'above'
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
      }
      name: 'parameters - 3'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| sort by TimeGenerated asc \r\n| extend \r\n    a=parse_json(Annotations_s),\r\n    f=parse_json(Field_s)\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))     \r\n| summarize \r\n    [\'Audit DateTime\']=max(TimeGenerated),\r\n    [\'Failed Checkpoints\']=countif(Outcome_s == \'Fail\'),\r\n    [\'Passed Checkpoints\']=countif(Outcome_s == \'Pass\'),\r\n    [\'Rules Checked\']=dcount(RuleName_s),\r\n    [\'Resources Checked\']=dcount(TargetName_s)\r\n  by \r\n    RunId_s\r\n//| project RunId_s, todatetime([\'Audit DateTime\']), [\'Rules Checked\'], [\'Resources Checked\'], [\'Failed Checkpoints\'], [\'Passed Checkpoints\']\r\n| sort by [\'Audit DateTime\'] desc\r\n| top 4 by [\'Audit DateTime\'] desc'
        size: 4
        timeContext: {
          durationMs: 2592000000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        visualization: 'tiles'
        tileSettings: {
          titleContent: {
            columnMatch: 'Audit DateTime'
            formatter: 6
            dateFormat: {
              formatName: 'shortDateTimePattern'
            }
            tooltipFormat: {
              tooltip: 'Audit date and time'
            }
          }
          subtitleContent: {
            columnMatch: 'Resources Checked'
            tooltipFormat: {
              tooltip: 'Resources checked'
            }
          }
          leftContent: {
            columnMatch: 'Failed Checkpoints'
            formatter: 12
            formatOptions: {
              palette: 'red'
            }
            tooltipFormat: {
              tooltip: 'Failed checkpoints'
            }
          }
          rightContent: {
            columnMatch: 'Passed Checkpoints'
            formatter: 12
            formatOptions: {
              palette: 'green'
              compositeBarSettings: {
                labelText: ''
                columnSettings: []
              }
            }
            tooltipFormat: {
              tooltip: 'Passed checkpoints'
            }
          }
          secondaryContent: {
            columnMatch: 'Rules Checked'
            formatter: 2
            formatOptions: {
              compositeBarSettings: {
                labelText: ''
                columnSettings: [
                  {
                    columnName: 'Failed Checkpoints'
                    color: 'redBright'
                  }
                  {
                    columnName: 'Passed Checkpoints'
                    color: 'green'
                  }
                ]
              }
            }
            tooltipFormat: {
              tooltip: 'Rules checked'
            }
          }
          showBorder: true
        }
        chartSettings: {
          xAxis: 'Audit DateTime'
          yAxis: [
            'Failed Checkpoints'
            'Passed Checkpoints'
            'Resources Checked'
            'Rules Checked'
          ]
          showLegend: true
        }
      }
      name: 'query - 4'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| sort by TimeGenerated asc \r\n| extend \r\n    a=parse_json(Annotations_s),\r\n    f=parse_json(Field_s)\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))     \r\n| summarize \r\n    [\'Audit DateTime\']=max(TimeGenerated),\r\n    [\'Failed Checkpoints\']=countif(Outcome_s == \'Fail\'),\r\n    [\'Passed Checkpoints\']=countif(Outcome_s == \'Pass\'),\r\n    [\'Rules Checked\']=dcount(RuleName_s),\r\n    [\'Resources Checked\']=dcount(TargetName_s)\r\n  by \r\n    RunId_s\r\n//| project RunId_s, todatetime([\'Audit DateTime\']), [\'Failed Checkpoints\'], [\'Passed Checkpoints\'], [\'Rules Checked\'], [\'Resources Checked\']\r\n| sort by [\'Audit DateTime\'] desc\r\n'
        size: 4
        aggregation: 5
        timeContext: {
          durationMs: 2592000000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        visualization: 'timechart'
        gridSettings: {
          formatters: [
            {
              columnMatch: 'Total Rules'
              formatter: 1
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoRuleSummaryId
                  typeSource: 'workbook'
                  gallerySource: 'workbook'
                  locationSource: 'default'
                  workbookName: 'Azure DevOps Summary by Rule'
                  viewerMode: true
                }
              }
            }
            {
              columnMatch: 'Total Resources'
              formatter: 1
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoResourceStateId
                  typeSource: 'workbook'
                  gallerySource: 'workbook'
                  locationSource: 'default'
                  workbookName: 'Azure DevOps Resource State'
                  viewerMode: true
                }
              }
            }
          ]
        }
        tileSettings: {
          showBorder: false
        }
        graphSettings: {
          type: 0
          topContent: {
            columnMatch: 'RunId_s'
            formatter: 1
          }
          centerContent: {
            columnMatch: 'Failed Checkpoints'
            formatter: 1
            numberFormat: {
              unit: 17
              options: {
                maximumSignificantDigits: 3
                maximumFractionDigits: 2
              }
            }
          }
        }
        chartSettings: {
          xAxis: 'Audit DateTime'
          showLegend: true
          showDataPoints: true
          ySettings: {
            numberFormatSettings: {
              unit: 17
              options: {
                style: 'decimal'
                useGrouping: true
              }
            }
          }
        }
      }
      name: 'query - 2 - Copy'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| sort by TimeGenerated asc \r\n| extend \r\n    a=parse_json(Annotations_s),\r\n    f=parse_json(Field_s)\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))     \r\n| summarize \r\n    [\'Audit DateTime\']=max(TimeGenerated),\r\n    [\'Failed Checkpoints\']=countif(Outcome_s == \'Fail\'),\r\n    [\'Passed Checkpoints\']=countif(Outcome_s == \'Pass\'),\r\n    [\'Rules Checked\']=dcount(RuleName_s),\r\n    [\'Resources Checked\']=dcount(TargetName_s)\r\n  by \r\n    RunId_s\r\n| project RunId_s, todatetime([\'Audit DateTime\']), [\'Rules Checked\'], [\'Resources Checked\'], [\'Failed Checkpoints\'], [\'Passed Checkpoints\']\r\n| sort by [\'Audit DateTime\'] desc\r\n'
        size: 0
        timeContext: {
          durationMs: 2592000000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        gridSettings: {
          formatters: [
            {
              columnMatch: 'RunId_s'
              formatter: 5
            }
            {
              columnMatch: 'Audit DateTime'
              formatter: 6
              formatOptions: {
                aggregation: 'Max'
              }
            }
            {
              columnMatch: 'Rules Checked'
              formatter: 7
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                aggregation: 'Max'
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoRuleSummaryId
                  typeSource: 'workbook'
                  gallerySource: 'workbook'
                  locationSource: 'default'
                  passSpecificParams: true
                  templateParameters: [
                    {
                      name: 'runId'
                      source: 'column'
                      value: 'RunId_s'
                    }
                    {
                      name: 'Organization'
                      source: 'parameter'
                      value: 'Organization'
                    }
                    {
                      name: 'Project'
                      source: 'parameter'
                      value: 'Project'
                    }
                  ]
                  viewerMode: false
                }
              }
            }
            {
              columnMatch: 'Resources Checked'
              formatter: 7
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                aggregation: 'Sum'
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoResourceStateId
                  typeSource: 'workbook'
                  gallerySource: 'workbook'
                  locationSource: 'default'
                  passSpecificParams: true
                  templateParameters: [
                    {
                      name: 'runId'
                      source: 'column'
                      value: 'RunId_s'
                    }
                    {
                      name: 'Organization'
                      source: 'parameter'
                      value: 'Organization'
                    }
                    {
                      name: 'Project'
                      source: 'parameter'
                      value: 'Project'
                    }
                  ]
                  viewerMode: false
                }
              }
            }
            {
              columnMatch: 'Failed Checkpoints'
              formatter: 0
              formatOptions: {
                aggregation: 'Sum'
              }
            }
            {
              columnMatch: 'Passed Checkpoints'
              formatter: 0
              formatOptions: {
                aggregation: 'Sum'
              }
            }
          ]
          sortBy: [
            {
              itemKey: 'Audit DateTime'
              sortOrder: 2
            }
          ]
        }
        sortBy: [
          {
            itemKey: 'Audit DateTime'
            sortOrder: 2
          }
        ]
      }
      name: 'query - 3'
    }
  ]
  fallbackResourceIds: [
    logAnalyticsWorkspaceId
  ]
  '$schema': 'https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json'
}

resource workbook_AzureDevOpsMain 'microsoft.insights/workbooks@2023-06-01' = {
  name: workbook_AzureDevOpsMain_Name
  location: location
  tags: {
    'hidden-title': 'Azure DevOps Main'
  }
  kind: 'shared'
  identity: {
    type: 'None'
  }
  properties: {
    displayName: 'Azure DevOps Main'
    version: 'Notebook/1.0'
    category: 'workbook'
    sourceId: logAnalyticsWorkspaceId
    serializedData: string(workbook)
  }
}
