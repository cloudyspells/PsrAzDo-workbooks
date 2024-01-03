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
