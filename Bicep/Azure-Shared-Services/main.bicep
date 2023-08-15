param location string = resourceGroup().location
param projectName string

// VNET Settings
param vnetName string
param vnetAddressPrefix string
param subnetList array

// Insights Settings, needs existing Log Analytics Workspace
param appInsightsName string
param logAnalyticsName string
param logAnalyticsResourceGroup string

// APIM Settings
param apiManagementName string
param selfHostedGatewayName string

param registryName string

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
