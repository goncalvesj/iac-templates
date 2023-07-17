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

// Function App Settings
param deployFunction = false
param functionAppName = toLower('${projectName}-functions')
param appInsightsName = toLower('${projectName}-appinsights')
param appServicePlanName = toLower('${projectName}-functionsplan')
param storageAccountName = toLower('${projectName}storage')
param logAnalyticsName = toLower('${projectName}-log-analytics')

// ADO Agent ACI Settings
param acrName = 'jprgacr'
param acrResourceGroup = 'JPRG-ALZ-Shared'

param aciName = toLower('${projectName}-ado-agent')
param adoOrgUrl = 'https://dev.azure.com/jpgoncalves/'
param adoAgentImage = 'jprgacr.azurecr.io/devops/ado-agent:dev'

// GET From
param adoPatToken = readEnvironmentVariable('ADO_PAT_TOKEN')
