# Azure Templates

The purpose of this repository is to provide examples of Azure ARM templates that I used to create different types of Azure Resources.

## ARM Templates

ARM Template that creates an Azure Storage Account to host Azure B2C custom UI files:

- [Azure B2C Storage Template](AzureArmTemplates/Azure.B2C.Storage)

ARM Template that creates Azure App Services that require the .Net Core 3.1 runtime:

- [Azure App Service w/ Extension Template](AzureArmTemplates/Azure.AppService.ExtensionAndSetting)

ARM Template that creates an Azure Storage Account, Function and Logic App:

- [Azure Logic App w/ Function Template](AzureArmTemplates/Azure.LogicApp.Function.Storage)

## Terraform Templates

Terraform Template that creates an Azure App Service for a Docker image pulled from Docker Hub

- [Azure App Service Docker](TerraformTemplates/Azure.AppService.Docker)

Terraform Template that creates an Azure AKS service with Managed Identity

- [Azure Kubernetes Service](TerraformTemplates/Azure.AppService.Docker)

## K8S Templates

Manifest file that creates a Kubernetes cluster issuer for Let's Encrypt certificates.

- [Let's Encrypt Cert Issuer](K8S/certissuers.yaml)

Manifest file that creates a Kubernetes NGINX ingress controller with a custom domain.

- [NGINX Ingress](K8S/ingress.yaml)
