param location string = resourceGroup().location
// Dev Center Settings
param projectName string
param deployDevCenter bool
param devCenterName string
// VNET Settings
param vnetName string
param vnetAddressPrefix string
param subnetList array
// Function Settings
param functionAppName string
param appInsightsName string
param appServicePlanName string
param storageAccountName string
param logAnalyticsName string

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    retentionInDays: 30
  }
}
// VNET & Dev Center Modules
module vnet 'modules/network.bicep' = {
  name: '${projectName}-vnet'
  params: {
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    list: subnetList
    vnetName: vnetName
  }
}

var devopsSubnetId = '${vnet.outputs.vnetId}/subnets/${subnetList[0].name}'

module devcenter 'modules/devcenter.bicep' = if(deployDevCenter) {
  name: '${projectName}-devcenter'
  params: {
    location: location //Not available in NEU
    name: devCenterName
    subnetId: devopsSubnetId
  }
}
// Function Module
module functions 'modules/functions.bicep' = {
  name: '${projectName}-functions'
  params: {
    location: location
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
    workspaceResourceId: logAnalytics.id
  }
}
