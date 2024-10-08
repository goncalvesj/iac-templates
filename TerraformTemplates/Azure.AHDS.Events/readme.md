# Azure AHDS Events

This Terraform template deploys an Event Based architecture based on Azure Health Data Services (AHDS) and Azure Event Grid.
The trigger for the flow is FHIR Resource Created event in AHDS. The event is captured by Event Grid and sent to a Service Bus topic.

The architecture includes the following resources:

## Provider Configuration

- Configures the `azurerm` provider.

## Resource Group

- Creates a resource group with specified location, name, and tags.

## Log Analytics Workspace

- Deploys a Log Analytics Workspace with retention, SKU, and identity settings.

## Virtual Network

- Creates a virtual network with subnets, NAT gateway, and network security group.
- Configures diagnostic settings to send logs to Log Analytics.

## NAT Gateway

- Deploys a NAT gateway with public IPs.

## Service Bus

- Creates a Service Bus namespace with topics and subscriptions.
- Assigns roles for Event Grid and App Service.
- Configures diagnostic settings.

## Event Grid

- Creates an Event Grid system topic and event subscription.
- Configures diagnostic settings for Event Grid.

## App Service

- Deploys an App Service with a service plan, virtual network integration, and managed identities.
- Enables Application Insights and configures diagnostic settings.

## Key Vault

- Creates a Key Vault with private endpoints and role assignments.
- Configures diagnostic settings.
