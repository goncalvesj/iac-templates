# Shared Services DevOps Infrastructure

Creates Azure services to host Azure Dev Center and ADO/GH Build Agents.

## Modules folder

Bicep modules that are used to define the Azure services.

- [rg.bicep](./modules/rg.bicep) - Creates Azure Resource Group.
- [network.bicep](./modules/network.bicep) - Creates Azure Virtual Network, Subnets and NSGs.
- [devcenter.bicep](./modules/devcenter.bicep) - Creates Azure Dev Center, Project and DevBox Definition.

## Files

[main.bicep](main.bicep) - Main Bicep file that creates the Azure services.

[deploy.ps1](deploy.ps1) - PowerShell script to execute the deployment of the Bicep files.

## Architecture

<!-- TODO -->
<!-- ![Architecture](./docs/architecture.png) -->

## Deployment

Use the VS Code Bicep extension to deploy the Bicep files. Right click on the [main.bicep](main.bicep) file and select "Deploy Bicep File". Save the deployment parameters in a file for future use.

Execute the [deploy-bicep.ps1](deploy-bicep.ps1) PowerShell script to deploy the Bicep files. Needs a deployment parameters file as input.
