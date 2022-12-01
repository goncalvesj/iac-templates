# .NET Service Bus Workers Infrastructure

Creates Azure services to host and run .NET Service Bus Worker applications.

[Link to Application Sample Repository](https://github.com/goncalvesj/application-templates/tree/master/AzureServiceBus-Worker-Notification)

## Modules folder

Bicep modules that are used to define the Azure services.

- [aks.bicep](./modules/aks.bicep) - Creates an Azure Kubernetes Service Cluster.
- [comm-services.bicep](modules/comm-services.bicep) - Creates Azure communication services and email domains.
- [event-grid.bicep](modules/event-grid.bicep) - Creates Azure Event Grid topics and subscriptions for storage events.
- [functions.bicep](modules/functions.bicep) - Creates Azure Functions for emails and real time notifications.
- [insights.bicep](modules/insights.bicep) - Creates Azure Application Insights to be used by the sample apps.
- [key-vault-secrets.bicep](modules/key-vault-secrets.bicep) - Creates Azure Key Vault secrets in azure key vault.
- [key-vault.bicep](modules/key-vault.bicep) - Creates Azure Key Vault.
- [network.bicep](modules/network.bicep) - Creates Azure Virtual Network and Subnets.
- [role-assignments.bicep](modules/role-assignments.bicep) - Creates Azure Role Assignments.
- [service-bus.bicep](modules/service-bus.bicep) - Creates Azure Service Bus and queues.
- [signalr.bicep](modules/signalr.bicep) - Creates Azure SignalR Service.
- [static-web-app.bicep](modules/static-web-app.bicep) - Creates Azure Static Web App to host the notifications client.
- [storage.bicep](modules/storage.bicep) - Creates Azure Storage Account and blob container.

## Files

[main.bicep](main.bicep) - Main Bicep file that creates the Azure services.

[deploy.ps1](deploy.ps1) - PowerShell script to execute the deployment of the Bicep files. Also added KEDA to the AKS cluster.

## AKS

The AKS cluster is created with the following configuration:

- 2 node pools (1 system pool and 1 user pool to run k8s jobs and queue processors)
  - User node pool scales down to 0 nodes when not in use
- Key Vault integration
- Virtual node integration with Azure Container Instances (to test the virtual node feature)

## Deployment

Use the VS Code Bicep extension to deploy the Bicep files. Right click on the [main.bicep](main.bicep) file and select "Deploy Bicep File". Save the deployment parameters in a file for future use.

Execute the [deploy-bicep.ps1](deploy-bicep.ps1) PowerShell script to deploy the Bicep files. Needs a deployment parameters file as input.

Execute the [deploy-keda.ps1](deploy-keda.ps1) PowerShell script to deploy KEDA in the AKS Cluster. Creates a K8S secret for the KEDA Auth Trigger.

Execute the [deploy-aci.ps1](deploy-aci.ps1) PowerShell script to deploy Virtual Nodes in the AKS Cluster. Used to test using Azure Container Instances as a node pool to run the queue processor.
