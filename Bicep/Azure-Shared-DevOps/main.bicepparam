using 'main.bicep'

param projectName = 'alzdevops'
param deployDevCenter = false
param devCenterName = 'JPRG-DevCenter'

// VNET Settings
param vnetName = toLower('${projectName}spokevnet')
param vnetAddressPrefix = '10.1.0.0/16'
param subnetList = [
  {
    name: 'DevBox-Subnet'
    value: '10.1.0.0/24'
    rules: []
  }
  {
    name: 'DevOpsAgents-Subnet'
    value: '10.1.1.0/24'
    rules: []
  }
]

param functionAppName = toLower('${projectName}-functions')
param appInsightsName = toLower('${projectName}-appinsights')
param appServicePlanName = toLower('${projectName}-functionsplan')
param storageAccountName = toLower('${projectName}storage')
param logAnalyticsName = toLower('${projectName}-log-analytics')
