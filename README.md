# Azure Templates

The purpose of this repository is to provide examples of Azure ARM templates that I used to create different types of Azure Resources.

## Bicep Templates

Bicep Template that creates an Azure App Service with Front Door and Private Endpoints:

- [AppService-FrontDoor-PrivateEndpoints](Bicep/AppService-FrontDoor-PrivateEndpoints)

Bicep Template for shared DevOps resources in Azure:

- [Azure-Shared-DevOps](Bicep/Azure-Shared-DevOps)

Bicep Template for shared services in Azure:

- [Azure-Shared-Services](Bicep/Azure-Shared-Services)

Bicep Template for an Azure OpenAI App Service chat demo:

- [AzureOpenAi-AppService-ChatDemo](Bicep/AzureOpenAi-AppService-ChatDemo)

Bicep Template for Azure Service Bus and worker notifications:

- [AzureServiceBus-Worker-Notification](Bicep/AzureServiceBus-Worker-Notification)

Bicep Template for baseline Azure Landing Zones:

- [Baseline-ALZ](Bicep/Baseline-ALZ)

## Terraform Templates

Terraform Template that creates an event driven architecture based on Azure Health Data Services event with Event Grid

- [Azure App Service Docker](Terraform/Azure.AHDS.Events)

Terraform Template that creates an Azure App Service for a Docker image pulled from Docker Hub

- [Azure App Service Docker](Terraform/Azure.AppService.Docker)

Terraform Template that creates an Azure AKS service with Managed Identity

- [Azure Kubernetes Service](Terraform/Azure.AppService.Docker)

## K8S Templates

Manifest file that creates a Kubernetes cluster issuer for Let's Encrypt certificates.

- [Let's Encrypt Cert Issuer](K8S/certissuers.yaml)

Manifest file that creates a Kubernetes NGINX ingress controller with a custom domain.

- [NGINX Ingress](K8S/ingress.yaml)
