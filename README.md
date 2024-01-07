# PSRule.Rules.AzureDevOps Azure Monitor Workbooks

## Overview

This repository contains an Azure Monitor Workbooks deployment
written in [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
for analyzing [PSRule.Rules.AzureDevOps](https://github.com/cloudyspells/PSRule.Rules.AzureDevOps)
results captured to an Azure Log Analytics workspace. Azure Pipelines and GitHub Actions
yaml templates are included to setup a daily analysis of Azure DevOps Organizations with
PSRule. The analysis will loop through all projects in the organization and capture
the results.

[![Demo video on YouTube](https://img.youtube.com/vi/x9crSs-6P-o/0.jpg)](https://www.youtube.com/watch?v=x9crSs-6P-o)

## Getting Started

The following steps will guide you through deploying the log analytics workspace and
workbooks to your Azure subscription.

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) version 2.20.0 or later.
- Local copy of this repository. Use `git clone` to download and maintain a local copy of this repo.

### Deployment

The following steps will guide you through deploying the log analytics workspace,
workbooks and a keyvault to your Azure subscription. In your local copy of this
repository, run the following command to create a new resource group:

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
    --query properties.outputs `
    -p azDoOrganization='contoso' `
    -p azDoPAT='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

The deployment will take approximately 5 minutes to complete. After the deployment
has completed, there will be a log analytics workspace with workbooks and a key vault
available in the resource group. The key vault will contain the necessary secrets
to run the analysis with PSRule from an Azure Pipeline.

### Azure Pipelines

The following steps will guide you through setting up a daily analysis of Azure DevOps projects
with PSRule using Azure Pipelines.

#### Create a repository in Azure DevOps

Create a new repository in Azure DevOps to store the pipeline definition. To create a new
repository, follow the steps in [Create a repo](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops&tabs=browser).
After creating the repository, clone it to your local machine and add the following files
to the root of the repository:

- `azure-pipelines/psrule-azdo-loganalytics.yaml`

#### Add the Key Vault as a Variable Group in Azure DevOps

Add the key vault as a variable group in Azure DevOps to allow the pipeline to access the
secrets. The key vault can be found in the resource group specified in the deployment.
To add the key vault as a variable group, follow the steps in [Create a variable group](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#create-a-variable-group).
When prompted to select a source, select `Azure Key Vault` and select the key vault created
in the previous step. Name the variable group `azdo-psrule-run` and select `Allow access to all pipelines`.

#### Create the pipeline

Create a new pipeline in Azure DevOps to run the PSRule analysis. To create a new pipeline,
follow the steps in [Create your first pipeline](https://docs.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline?view=azure-devops&tabs=java%2Cyaml%2Cbrowser%2Ctfs-2018-2).
When prompted to select a template, select `Existing Azure Pipelines YAML file` and
select the `azure-pipelines/psrule-azdo-loganalytics.yaml` file from the repository.

#### Run the pipeline

Run the pipeline to verify the setup. The pipeline will run for approximately 2 to 5 minutes depending on the size of the Azure DevOps project. Do not run the pipeline more
than once a day as the workbook is designed to analyze a single day of data.

**Note:** When running the pipeline for the first time, it will take up to 15 minutes
for data to appear in the workbook.

#### Check the workbook

After the pipeline has completed, check the workbook in the log analytics workspace.
The main workbook is named `Azure DevOps Main` and is available in the `Workbooks` section
of the log analytics workspace. The workbook will show the results of the last run in 24
hour intervals.

## References and acknowledgements

- [PSRule](https://microsoft.github.io/PSRule) by [@BernieWhite](https://github.com/BernieWhite)
- [PSRule.Monitor](https://github.com/microsoft/PSRule.Monitor) by [@BernieWhite](https://github.com/BernieWhite)
- [PSRule.Rules.AzureDevOps](https://github.com/cloudyspells/PSRule.Rules.AzureDevOps) by [Roderick Bant](https://github.com/webtonize)
