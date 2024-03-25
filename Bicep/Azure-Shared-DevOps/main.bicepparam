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
  {
    name: 'ACI-Subnet'
    value: '10.1.2.0/24'
    rules: []
  }
]

// Function App Settings
param deployFunction = true
param functionAppName = toLower('${projectName}-function')
param appInsightsName = toLower('${projectName}-appinsights')
param appServicePlanName = toLower('${projectName}-functionsplan')
param storageAccountName = toLower('${projectName}functionstorage')
param logAnalyticsName = toLower('${projectName}-log-analytics')

// ADO Agent ACI Settings
param acrName = 'jprgacr'
param acrResourceGroup = 'JPRG-ALZ-Shared'

param aciName = toLower('${projectName}-ado-agent')
param adoOrgUrl = 'https://dev.azure.com/jpgoncalves/'
param adoAgentImage = 'jprgacr.azurecr.io/devops/ado-agent:dev'

// GET From Environment Variables
// Build Agent PAT Tokens
param adoBuildAgentPatToken = readEnvironmentVariable('ADO_PAT_TOKEN', 'DEFAULT_VALUE')
// Function App PAT Tokens
param adoFunctionPatToken = readEnvironmentVariable('ADOGHSYNC_ADO_PAT', 'DEFAULT_VALUE')
param ghPatToken = readEnvironmentVariable('ADOGHSYNC_GH_PAT', 'DEFAULT_VALUE')
