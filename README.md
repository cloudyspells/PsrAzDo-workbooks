# PSRule.Rules.AzureDevOps Azure Monitor Workbooks

## Overview

This repository contains an Azure Monitor Workbooks deployment
written in [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
for analyzing [PSRule.Rules.AzureDevOps](https://github.com/cloudyspells/PSRule.Rules.AzureDevOps)
results captured to an Azure Log Analytics workspace. Azure Pipelines and GitHub Actions yaml
templates are included to setup a daily analysis of Azure DevOps projects with PSRule.



## Getting Started

The following steps will guide you through deploying the log analytics workspace and
workbooks to your Azure subscription.

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) version 2.20.0 or later.
- Local copy of this repository. Use `git clone` to download and maintain a local copy of this repo.

### Deployment

The following steps will guide you through deploying the log analytics workspace and workbooks
to your Azure subscription. In your local copy of this repository, run the following command
to create a new resource group:

```powershell
# Set the location to deploy to
$location = 'westeurope'
# Set the resource group name
$resourceGroupName = 'rg-psrule-azuredevops-weu'
# Create the resource group in the specified location
az group create --name $resourceGroupName --location $location
```

Next, run the following command to deploy the log analytics workspace and workbooks:

```powershell
az deployment group create `
    --resource-group $resourceGroupName `
    --template-file .\src\bicep\main.bicep `
    --query properties.outputs
```

The deployment will run for approximately 5 minutes. Once complete, the output will
contain the following properties:

```json
{
  "logAnalyticSharedKey": {
    "type": "String",
    "value": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  },
  "logAnalyticsWorkspaceId": {
    "type": "String",
    "value": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}
```

take note of the `value` for `logAnalyticsWorkspaceId` and `logAnalyticSharedKey` as
these will be used in in setting up the variables for the Azure Pipelines and GitHub
Actions templates.

**Note:** The log analytics workspace and the newly created table will take approximately
15 minutes to show data upon initial creation.


### Azure Pipelines

The following steps will guide you through setting up a daily analysis of Azure DevOps projects
with PSRule using Azure Pipelines.

#### Create a repository in Azure DevOps

Create a new repository in Azure DevOps to store the pipeline definition. To create a new
repository, follow the steps in [Create a repo](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops&tabs=browser).
After creating the repository, clone it to your local machine and add the following files
to the root of the repository:

- `azure-pipelines/psrule-azdo-loganalytics.yaml`

#### Create a Key Vault

Create a new key vault to store the log analytics workspace id and shared key and also
the Azure DevOps personal access token, Organization and Project name for inspection
by PSRule. To create a new key vault, follow the steps in [Create a key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal#create-a-key-vault).
After creating the key vault, add the following secrets:

- `logAnalyticsWorkspaceId` - The value of `logAnalyticsWorkspaceId` from the deployment output.
- `logAnalyticSharedKey` - The value of `logAnalyticSharedKey` from the deployment output.
- `AZDO_PAT` - A personal access token for Azure DevOps with full access to the organization and project.
- `AZDO_ORGANIZATION` - The name of the Azure DevOps organization.
- `AZDO_PROJECT` - The name of the Azure DevOps project.

#### Create the pipeline

Create a new pipeline in Azure DevOps to run the PSRule analysis. To create a new pipeline,
follow the steps in [Create your first pipeline](https://docs.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline?view=azure-devops&tabs=java%2Cyaml%2Cbrowser%2Ctfs-2018-2).
When prompted to select a template, select `Existing Azure Pipelines YAML file` and
select the `azure-pipelines/psrule-azdo-loganalytics.yaml` file from the repository.

#### Run the pipeline

Run the pipeline to verify the deployment. The pipeline will run for approximately 2 to 5 minutes depending on the size of the Azure DevOps project. Do not run the pipeline more
than once a day as the workbook is designed to analyze a single day of data.

#### Check the workbook

After the pipeline has completed, check the workbook in the log analytics workspace.
The main workbook is named `Azure DevOps Main` and is available in the `Workbooks` section
of the log analytics workspace. The workbook will show the results of the last run in 24
hour intervals.
