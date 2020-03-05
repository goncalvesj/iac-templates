# Azure Logic App with Storage and Function ARM Template

This templates creates the following:

- Azure Storage Account with Storage File Share
- Logic App with Azure Service Bus Topic connection
- Function App with associated Storage Account and App Insights

## Logic App Flow
1. Message is received
2. Function App is executed
3. Message is completed or sent to deadletter

![LogicAppFlow](LogicAppFlow.png)

## Azure Resources

![AzureResources](AzureResources.png)