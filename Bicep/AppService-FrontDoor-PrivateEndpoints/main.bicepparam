using './main.bicep'

param projectName = 'alzappfdpe'
param resourceGroupName = 'ALZ-AppFDPE-RG'
param location = 'northeurope'

// VNET Settings
param vnetName = toLower('${projectName}spokevnet')
param vnetAddressPrefix = '10.2.0.0/16'
param appSubnetName = 'APP-Subnet'
param appSubnetAddress = '10.2.1.0/24'
param storageSubnetName = 'STORAGE-Subnet'
param storageSubnetAddress = '10.2.0.0/29'
param kvSubnetName = 'KV-Subnet'
param kvSubnetAddress = '10.2.2.0/29'
param cacheSubnetName = 'REDIS-Subnet'
param cacheSubnetAddress = '10.2.3.0/29'
param sqlSubnetName = 'SQL-Subnet'
param sqlSubnetAddress = '10.2.4.0/29'

// Key Vault Settings
param kvName = toLower('${projectName}kv')

// Storage Settings
param storageAccountName = toLower('${projectName}storage')
param storageSkuName = 'Standard_LRS'
param storageInputBlobContainerName = 'static-files'

// App Service Settings
param appPlanName = toLower('${projectName}plan')
param appServiceName = toLower('${projectName}app')

// Cache Settings
param cacheName = toLower('${projectName}cache')

// SQL Settings
param sqlServerName = toLower('${projectName}sqlserver')
param sqlAdministratorLogin = projectName
@secure()
param sqlAdministratorLoginPassword = 'CHANGE_ME!'

// Front Door Settings
param frontDoorSkuName = 'Premium_AzureFrontDoor'
param frontDoorProfileName = toLower('${projectName}frontdoor')
