targetScope = 'resourceGroup'

@description('Azure DevOps Resource State Workbook template ID')
param AzDoRuleHitsByResourceId string

@description('Log Analytics Workspace Resource ID')
param logAnalyticsWorkspaceId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the workbook.')
param workbook_AzureDevOpsResourceState_Name string = '855547f3-9ea7-4a88-8065-bcfc88a9224e'

var workbook = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 9
      content: {
        version: 'KqlParameterItem/1.0'
        parameters: [
          {
            id: '168ebd5b-4dec-441f-aa49-6a1d239a7a2e'
            version: 'KqlParameterItem/1.0'
            name: 'runId'
            label: 'Run ID'
            type: 2
            description: 'Select Run ID to display'
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
            value: 'psrule-scan-ado/287'
          }
          {
            id: 'ae4e2baa-2cc1-4dc6-a31b-0b0ca2dcf2c1'
            version: 'KqlParameterItem/1.0'
            name: 'Organization'
            type: 2
            description: 'Select Azure DevOps Organizations to display'
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
            value: [
              'value::all'
            ]
          }
          {
            id: 'c3cf7295-b99d-448c-abef-4194c8f78c44'
            version: 'KqlParameterItem/1.0'
            name: 'Project'
            type: 2
            description: 'Select Azure DevOps Project to display'
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
              showDefault: false
            }
            timeContext: {
              durationMs: 2592000000
            }
            defaultValue: 'value::all'
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
            value: [
              'psrule-scan-ado'
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
        query: 'PSRule_CL\r\n| where RunId_s == \'{runId:value}\'\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend [\'Resource Id\']=f.id, Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))\r\n| extend severity_level = case(\r\n    Severity == "Informational" and Outcome_s == \'Fail\', 1,\r\n    Severity == "Important" and Outcome_s == \'Fail\', 2,\r\n    Severity == "Severe" and Outcome_s == \'Fail\', 3,\r\n    Severity == "Critical" and Outcome_s == \'Fail\', 4,\r\n    0)\r\n| summarize\r\n        [\'Resource state\'] = arg_max(severity_level, *),\r\n        [\'Failed checkpoints\'] = countif(Outcome_s == \'Fail\')\r\n    by tostring(TargetName_s)\r\n| extend Findings = case(\r\n    [\'Resource state\'] == 1, "Informational",\r\n    [\'Resource state\'] == 2, "Important",\r\n    [\'Resource state\'] == 3, "Severe",\r\n    [\'Resource state\'] == 4, "Critical",\r\n    [\'Resource state\'] == 0, "Passed all rules",\r\n    "Not found")\r\n| project [\'Resource FQN\'] = TargetName_s, [\'Resource Type\'] = TargetType_s, Findings, [\'Failed checkpoints\']\r\n| summarize [\'Resources\'] = dcount([\'Resource FQN\']) by Findings\r\n| render piechart with (xcolumn=Findings, ycolumns=Resources)\r\n\r\n'
        size: 4
        timeContext: {
          durationMs: 2592000000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        tileSettings: {
          showBorder: false
          titleContent: {
            columnMatch: 'Severity'
            formatter: 1
          }
          leftContent: {
            columnMatch: 'Failed Resources'
            formatter: 12
            formatOptions: {
              palette: 'auto'
            }
            numberFormat: {
              unit: 17
              options: {
                maximumSignificantDigits: 3
                maximumFractionDigits: 2
              }
            }
          }
        }
        graphSettings: {
          type: 0
          topContent: {
            columnMatch: 'Severity'
            formatter: 1
          }
          centerContent: {
            columnMatch: 'Failed Resources'
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
          showLegend: true
        }
      }
      name: 'severity-summary'
    }
    {
      type: 11
      content: {
        version: 'LinkItem/1.0'
        style: 'tabs'
        links: [
          {
            id: '1003f604-5dfd-4e1d-89a1-81e0278387ec'
            cellValue: 'SeverityFilter'
            linkTarget: 'parameter'
            linkLabel: 'All Resources'
            subTarget: 'All Resources'
            style: 'link'
          }
          {
            id: '538038ac-54cd-4148-a21f-e1532abe1869'
            cellValue: 'SeverityFilter'
            linkTarget: 'parameter'
            linkLabel: 'Critical'
            subTarget: 'Critical'
            style: 'link'
            linkIsContextBlade: true
          }
          {
            id: '40feacf0-8046-4bd8-8fab-269fa3310334'
            cellValue: 'SeverityFilter'
            linkTarget: 'parameter'
            linkLabel: 'Severe'
            subTarget: 'Severe'
            style: 'link'
            linkIsContextBlade: true
          }
          {
            id: 'bcb30b4a-5d4b-40a9-8268-cb8ccabeea08'
            cellValue: 'SeverityFilter'
            linkTarget: 'parameter'
            linkLabel: 'Important'
            subTarget: 'Important'
            style: 'link'
          }
          {
            id: 'ccb04891-e9fd-4e4e-853a-1b9f91711af6'
            cellValue: 'SeverityFilter'
            linkTarget: 'parameter'
            linkLabel: 'Informational'
            subTarget: 'Informational'
            style: 'link'
          }
          {
            id: '45952de9-4ca6-4d0a-981f-58cad3d21b6b'
            cellValue: 'SeverityFilter'
            linkTarget: 'parameter'
            linkLabel: 'Passed all rules'
            subTarget: 'Passed all rules'
            style: 'link'
          }
        ]
      }
      name: 'links - 2'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| where RunId_s == \'{runId:value}\'\r\n| extend a=parse_json(Annotations_s), f=parse_json(Field_s)\r\n| extend Severity=a.severity, [\'Rule Help Url\']=a.[\'online version\'],Category=a.category\r\n| extend \r\n    expandedId=parse_json(tostring(f.id))\r\n| extend \r\n    Organization=expandedId.organization,\r\n    [\'Project\']=expandedId.[\'project\'],\r\n    ResourceName=expandedId.resourceName\r\n| where (Organization in ({Organization}) or \'All Organizations\' in ({Organization})) and (Project in ({Project}) or \'All Projects\' in ({Project}))    \r\n| extend severity_level = case(\r\n    Severity == "Informational" and Outcome_s == \'Fail\', 1,\r\n    Severity == "Important" and Outcome_s == \'Fail\', 2,\r\n    Severity == "Severe" and Outcome_s == \'Fail\', 3,\r\n    Severity == "Critical" and Outcome_s == \'Fail\', 4,\r\n    0)\r\n| summarize\r\n        [\'Resource state\'] = arg_max(severity_level, *),\r\n        [\'Failed Rules\'] = countif(Outcome_s == \'Fail\'),\r\n        [\'Passed Rules\'] = countif(Outcome_s == \'Pass\')\r\n    by tostring(TargetName_s)\r\n| sort by [\'Resource state\'] desc\r\n| extend Findings = case(\r\n    [\'Resource state\'] == 1, "Informational",\r\n    [\'Resource state\'] == 2, "Important",\r\n    [\'Resource state\'] == 3, "Severe",\r\n    [\'Resource state\'] == 4, "Critical",\r\n    [\'Resource state\'] == 0, "Passed all rules",\r\n    "Not found")\r\n| project Organization, Project, [\'Resource Name\']=ResourceName, [\'Resource Type\'] = TargetType_s, Findings, [\'Failed Rules\'], [\'Passed Rules\'], [\'Resource FQN\'] = TargetName_s\r\n| where Findings == \'{SeverityFilter}\' or \'All Resources\' == \'{SeverityFilter}\'\r\n'
        size: 0
        timeContext: {
          durationMs: 2592000000
        }
        exportedParameters: [
          {
            fieldName: 'Resource FQN'
            parameterName: 'resourceName'
            defaultValue: 'All Resources'
          }
          {
            parameterType: 1
          }
        ]
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        gridSettings: {
          formatters: [
            {
              columnMatch: 'Resource Name'
              formatter: 7
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                linkIsContextBlade: true
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoRuleHitsByResourceId
                  typeSource: 'workbook'
                  gallerySource: 'workbook'
                  locationSource: 'default'
                  workbookName: 'Resource Rule details'
                  passSpecificParams: true
                  templateParameters: [
                    {
                      name: 'resourceName'
                      source: 'column'
                      value: 'Resource FQN'
                    }
                    {
                      name: 'runId'
                      source: 'parameter'
                      value: 'runId'
                    }
                  ]
                  viewerMode: false
                }
              }
            }
            {
              columnMatch: 'Findings'
              formatter: 18
              formatOptions: {
                thresholdsOptions: 'icons'
                thresholdsGrid: [
                  {
                    operator: '=='
                    thresholdValue: 'Passed all rules'
                    representation: 'success'
                    text: '{0}{1}'
                  }
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
              columnMatch: 'Resource FQN'
              formatter: 7
              formatOptions: {
                linkTarget: 'WorkbookTemplate'
                linkIsContextBlade: true
                workbookContext: {
                  componentIdSource: 'workbook'
                  resourceIdsSource: 'workbook'
                  templateIdSource: 'static'
                  templateId: AzDoRuleHitsByResourceId
                  typeSource: 'default'
                  gallerySource: 'default'
                  locationSource: 'default'
                  workbookName: 'Resource Rule details'
                  passSpecificParams: true
                  templateParameters: [
                    {
                      name: 'resourceName'
                      source: 'cell'
                      value: ''
                    }
                  ]
                  viewerMode: true
                }
                customColumnWidthSetting: '70ch'
              }
            }
            {
              columnMatch: 'Severity'
              formatter: 5
            }
            {
              columnMatch: 'Rule Help Url'
              formatter: 7
              formatOptions: {
                linkTarget: 'Url'
              }
            }
          ]
        }
        sortBy: []
      }
      name: 'rule-results-filtered'
    }
  ]
  fallbackResourceIds: [
    logAnalyticsWorkspaceId
  ]
  '$schema': 'https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json'
}

resource workbook_AzureDevOpsResourceState 'microsoft.insights/workbooks@2023-06-01' = {
  name: workbook_AzureDevOpsResourceState_Name
  location: location
  tags: {
    'hidden-title': 'Azure DevOps Resource State'
  }
  kind: 'shared'
  identity: {
    type: 'None'
  }
  properties: {
    displayName: 'Azure DevOps Resource State'
    version: 'Notebook/1.0'
    category: 'workbook'
    sourceId: logAnalyticsWorkspaceId
    serializedData: string(workbook)
  }
}

output id string = workbook_AzureDevOpsResourceState.id
