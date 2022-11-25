param appName string = ''
param storageAccountType string = 'Standard_LRS'
param location string = resourceGroup().location
param appInsightsLocation string = location

param runtime string = 'dotnet'

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName
var storageAccountName = '${appName}storage'

param clientAppUrl string = ''

param signalRName string = ''
param commsServiceName string = ''
param serviceBusRuleId string = ''

param commsServiceSender string = '39aaaa57-0e7d-4ebc-ad64-276e33912e71.azurecomm.net'
param destinationEmail string = 'test@gmail.com'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  properties: {
    // computeMode: 'Dynamic'
    reserved: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET|6.0'
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: [
          // 'https://localhost:7044' FOR LOCAL DEV
          'https://${clientAppUrl}'
        ]
      }
    }
    httpsOnly: true
  }
}

resource signalr 'Microsoft.SignalRService/signalR@2022-02-01' existing = {
  name: signalRName
}

resource lzcommservices 'Microsoft.Communication/communicationServices@2022-07-01-preview' existing = {
  name: commsServiceName
}


var azureSignalRConnectionString = signalr.listKeys().primaryConnectionString
var commsServiceConnectionString = lzcommservices.listKeys().primaryConnectionString
var serviceBusConnectionString = listKeys(serviceBusRuleId, '2022-01-01-preview').primaryConnectionString

var BASE_SLOT_APPSETTINGS = {
  APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
  APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
  AzureSignalRConnectionString: azureSignalRConnectionString
  CommsServiceConnectionString: commsServiceConnectionString
  CommsServiceSender: 'DoNotReply@${commsServiceSender}'
  DestinationEmail: destinationEmail
  ServiceBusConnectionString: serviceBusConnectionString
  AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: runtime
  WEBSITE_CONTENTSHARE: toLower(storageAccountName)
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
}

resource functionAppSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/appsettings'
  properties: BASE_SLOT_APPSETTINGS
  dependsOn: [
    functionApp
  ]
}
