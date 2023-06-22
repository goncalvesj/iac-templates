param location string = resourceGroup().location
param apiManagementName string
param selfHostedGatewayName string
param apimSubnetId string
param appInsightsId string
param appInsightsName string
param appInsightsInstrumentationKey string

// API Management Instance
resource apiManagement 'Microsoft.ApiManagement/service@2022-09-01-preview' = {
  name: apiManagementName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Developer'
    capacity: 1
  }
  properties: {
    apiVersionConstraint: {
      minApiVersion: '2019-12-01'
    }
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
    }
    publisherName: 'JPRG'
    publisherEmail: 'testemail@gmail.com'
    virtualNetworkType: 'External'
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
  }
}

// Gateway
resource selfHostedGateway 'Microsoft.ApiManagement/service/gateways@2022-09-01-preview' = {
  name: selfHostedGatewayName
  parent: apiManagement
  properties: {
    description: 'Self-hosted API Gateway on Azure Container Apps'
    locationData: {
      name: 'On-Prem MicroK8s'
      countryOrRegion: 'Cloud'
    }
  }
}

// Application Insights
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2022-09-01-preview' = {
  name: appInsightsName
  parent: apiManagement
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

output apiManagementName string = apiManagement.name
