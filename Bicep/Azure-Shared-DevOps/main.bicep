param location string = resourceGroup().location
param adoOrgUrl string

// Dev Center Settings
param projectName string
param deployDevCenter bool
param devCenterName string
// VNET Settings
param vnetName string
param vnetAddressPrefix string
param subnetList array
// Function Settings
param deployFunction bool
param functionAppName string
param appInsightsName string
param appServicePlanName string
param storageAccountName string
param logAnalyticsName string
@secure()
param adoFunctionPatToken string
@secure()
param ghPatToken string
// ACI Settings
param acrName string
param acrResourceGroup string
param aciName string
param adoAgentImage string
@secure()
param adoBuildAgentPatToken string

// VNET Module
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
// Dev Center Module
module devcenter 'modules/devcenter.bicep' = if(deployDevCenter) {
  name: '${projectName}-devcenter'
  params: {
    location: location //Not available in NEU
    name: devCenterName
    subnetId: devopsSubnetId
  }
}
// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = if(deployFunction) {
  name: logAnalyticsName
  location: location
  properties: {
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    retentionInDays: 30
  }
}
// Function Module
module functions 'modules/functions.bicep' = if(deployFunction) {
  name: '${projectName}-functions'
  params: {
    location: location
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    storageAccountName: storageAccountName
    workspaceResourceId: logAnalytics.id
    AZUREDEVOPS_ORG: adoOrgUrl
    AZUREDEVOPS_PAT: adoFunctionPatToken
    GITHUB_PAT: ghPatToken
  }
}
// ACI Module
module aci 'modules/aci.bicep' = {
  name: '${projectName}-aci'
  params: {
    location: location
    acrName: acrName
    acrResourceGroup: acrResourceGroup
    aciName: aciName
    adoOrgUrl: adoOrgUrl
    adoAgentImage: adoAgentImage
    adoPatToken: adoBuildAgentPatToken
  }
}
