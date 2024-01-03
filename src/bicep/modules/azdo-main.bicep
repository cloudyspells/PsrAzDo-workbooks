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
      type: 11
      content: {
        version: 'LinkItem/1.0'
        style: 'bullets'
        links: [
          {
            id: 'e1a9ace8-f268-4f21-b289-72c4a2355d7c'
            linkTarget: 'WorkbookTemplate'
            linkLabel: 'Azure DevOps Resource States'
            preText: ''
            style: 'link'
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
          {
            id: 'a67b38b4-6216-4724-af7a-2b719fb4414c'
            linkTarget: 'WorkbookTemplate'
            linkLabel: 'Azure DevOps Rule Summary'
            style: 'link'
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
        ]
      }
      name: 'links - 1'
    }
    {
      type: 3
      content: {
        version: 'KqlItem/1.0'
        query: 'PSRule_CL\r\n| summarize\r\n    [\'Total Rules\']=dcount(DisplayName_s),\r\n    [\'Total Resources\']=dcount(TargetName_s)\r\n'
        size: 4
        timeContext: {
          durationMs: 86400000
        }
        queryType: 0
        resourceType: 'microsoft.operationalinsights/workspaces'
        visualization: 'table'
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
      }
      name: 'query - 2'
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
