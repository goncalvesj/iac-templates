param location string = resourceGroup().location
param tenantId string = subscription().tenantId

param projectName string = 'lztest'

// VNET Settings
param vnetName string = toLower('${projectName}spokevnet')
param vnetAddressPrefix string = '10.2.0.0/16'
param appSubnetName string = 'APP-Subnet'
param appSubnetAddress string = '10.2.1.0/24'
param storageSubnetName string = 'STORAGE-Subnet'
param storageSubnetAddress string = '10.2.0.0/29'
param kvSubnetName string = 'KV-Subnet'
param kvSubnetAddress string = '10.2.2.0/29'
param cacheSubnetName string = 'REDIS-Subnet'
param cacheSubnetAddress string = '10.2.3.0/29'
param sqlSubnetName string = 'SQL-Subnet'
param sqlSubnetAddress string = '10.2.4.0/29'

// Key Vault Settings
param kvName string = toLower('${projectName}kv')

// Storage Settings
param storageAccountName string = toLower('${projectName}storage')
param storageSkuName string = 'Standard_LRS'
param storageInputBlobContainerName string = 'static-files'

// App Service Settings
param appPlanName string = toLower('${projectName}plan')
param appServiceName string = toLower('${projectName}app')

// Cache Settings
param cacheName string = toLower('${projectName}cache')

// SQL Settings
param sqlServerName string = toLower('${projectName}sqlserver')
param sqlAdministratorLogin string = 'CHANGE_ME'
@secure()
param sqlAdministratorLoginPassword string = ''


// Front Door Settings
param frontDoorSkuName string = 'Premium_AzureFrontDoor'
param frontDoorProfileName string = toLower('${projectName}frontdoor')

module vnet 'modules/network.bicep' = {
  name: '${projectName}-vnet'
  params: {
    location: location
    appSubnetAddress: appSubnetAddress
    appSubnetName: appSubnetName
    cacheSubnetAddress: cacheSubnetAddress
    cacheSubnetName: cacheSubnetName
    kvSubnetAddress: kvSubnetAddress
    kvSubnetName: kvSubnetName
    storageSubnetAddress: storageSubnetAddress
    storageSubnetName: storageSubnetName
    sqlSubnetAddress: sqlSubnetAddress
    sqlSubnetName: sqlSubnetName
    vnetAddressPrefix: vnetAddressPrefix
    vnetName: vnetName
  }
}

module kv 'modules/key-vault.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-key-vault'
  params: {
    keysPermissions: []
    keyVaultName: kvName
    location: location
    objectId: 'e1f30c95-92c5-444f-85d0-7606c9244349'
    subnetId: vnet.outputs.kvSubnetId
    virtualNetworkId: vnet.outputs.vnetId
    secretsPermissions: [
      'all'
    ]
    skuName: 'standard'
    tenantId: tenantId
  }
}

module storage 'modules/storage.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-storage'
  params: {
    accountName: storageAccountName
    inputBlobContainerName: storageInputBlobContainerName
    location: location
    skuName: storageSkuName
    subnetId: vnet.outputs.storageSubnetId
    virtualNetworkId: vnet.outputs.vnetId
  }
}

module appservice 'modules/app-service.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-app-service'
  params: {
    appPlanName: appPlanName
    appServiceName: appServiceName
    appSubnetId: vnet.outputs.appSubnetId
    location: location
  }
}

module cache 'modules/cache.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-cache'
  params: {
    name: cacheName
    location: location
    subnetId: vnet.outputs.cacheSubnetId
    virtualNetworkId: vnet.outputs.vnetId
  }
}

module sql 'modules/sql.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-sql'
  params: {
    location: location
    subnetId: vnet.outputs.sqlSubnetId
    virtualNetworkId: vnet.outputs.vnetId
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    sqlServerName: sqlServerName
  }
}

module frontdoor 'modules/front-door.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-frontdoor'
  params: {
    frontDoorProfileName: frontDoorProfileName
    frontDoorSkuName: frontDoorSkuName
  }
}

var storageOriginHostName = storage.outputs.blobEndpointHostName
var storageOriginHostType = 'blob'
var storageId = storage.outputs.storageResourceId

module storageFrontDoorEndpoint 'modules/front-door-endpoint.bicep' = {
  dependsOn: [
    frontdoor
    storage
  ]
  name: '${projectName}-afd-storage-endpoint'
  params: {
    frontDoorEndpointName: 'storage-${uniqueString(resourceGroup().id)}'
    frontDoorProfileName: frontDoorProfileName
    frontDoorOriginName: 'storage-origin'
    originHostName: storageOriginHostName
    privateEndpointLocation: location
    privateEndpointResourceId: storageId
    privateLinkResourceType: storageOriginHostType
  }
}

var appOriginHostName = appservice.outputs.appHostName
var appOriginHostType = 'sites'
var appServiceId = appservice.outputs.appServiceResourceId

module appFrontDoorEndpoint 'modules/front-door-endpoint.bicep' = {
  dependsOn: [
    frontdoor
    appservice
  ]
  name: '${projectName}-afd-app-endpoint'
  params: {
    frontDoorEndpointName: 'app-${uniqueString(resourceGroup().id)}'
    frontDoorProfileName: frontDoorProfileName
    frontDoorOriginName: 'app-origin'
    originHostName: appOriginHostName
    privateEndpointLocation: location
    privateEndpointResourceId: appServiceId
    privateLinkResourceType: appOriginHostType
  }
}
