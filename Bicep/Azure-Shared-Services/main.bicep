param location string = resourceGroup().location
param projectName string = 'alzshared'

// VNET Settings
param vnetName string = toLower('${projectName}spokevnet')
param vnetAddressPrefix string = '10.4.0.0/16'
param subnetList array = [
  {
    name: 'APIM-Subnet'
    value: '10.4.1.0/24'
    rules: [
      {
        name: 'AllowHTTP'
        properties: {
          description: 'Allow HTTP'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          description: 'Allow HTTPS'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }        
      }
      {
        name: 'Allow3443Inbound'
        properties: {
          description: 'Allow 3443'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }        
      }
    ]
  }
]

// Insights Settings, needs existing Log Analytics Workspace
param appInsightsName string = toLower('${projectName}appinsights')
param logAnalyticsName string = 'jprg-alz-log-analytics'
param logAnalyticsResourceGroup string = 'jprg-alz-management'

// APIM Settings
param apiManagementName string = toLower('${projectName}apim')
param selfHostedGatewayName string = toLower('${projectName}apimhostedgateway')

param registryName string = 'jprgacr'

// Get Existing Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
  scope: resourceGroup(logAnalyticsResourceGroup)
}

var laId = logAnalytics.id

// Deploy VNET
module vnet 'modules/network.bicep' = {
  name: '${projectName}-vnet'
  params: {
    location: location
    list: subnetList
    vnetAddressPrefix: vnetAddressPrefix
    vnetName: vnetName
  }
}
var apimSubnetId = '${vnet.outputs.vnetId}/subnets/${subnetList[0].name}'

// Deploy App Insights
module insights 'modules/insights.bicep' = {
  dependsOn: [
    logAnalytics
  ]
  name: '${projectName}-app-insights'
  params: {
    appInsightsName: appInsightsName
    location: location
    workspaceResourceId: laId
  }
}

// Deploy APIM
module apim 'modules/apim.bicep' = {
  dependsOn: [
    vnet
    insights
  ]
  name: '${projectName}-apim'
  params: {
    location: location
    apiManagementName: apiManagementName
    selfHostedGatewayName: selfHostedGatewayName
    apimSubnetId: apimSubnetId
    appInsightsName: appInsightsName
    appInsightsId: insights.outputs.appInsightsId
    appInsightsInstrumentationKey: insights.outputs.appInsightsInstrumentationKey
  }
}

// Deploy ACR
module acr 'modules/acr.bicep' = {
  name: '${projectName}-acr'
  params: {
    location: location
    registryName: registryName
  }
}
