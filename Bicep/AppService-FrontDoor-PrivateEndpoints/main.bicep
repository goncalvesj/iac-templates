targetScope = 'subscription'

// param location string = resourceGroup().location
param location string
param tenantId string = subscription().tenantId

param projectName string
param resourceGroupName string

// VNET Settings
param vnetName string
param vnetAddressPrefix string
param appSubnetName string
param appSubnetAddress string
param storageSubnetName string
param storageSubnetAddress string
param kvSubnetName string
param kvSubnetAddress string
param cacheSubnetName string
param cacheSubnetAddress string
param sqlSubnetName string
param sqlSubnetAddress string

// Key Vault Settings
param kvName string

// Storage Settings
param storageAccountName string
param storageSkuName string
param storageInputBlobContainerName string

// App Service Settings
param appPlanName string
param appServiceName string

// Cache Settings
param cacheName string

// SQL Settings
param sqlServerName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string

// Front Door Settings
param frontDoorSkuName string
param frontDoorProfileName string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module vnet 'modules/network.bicep' = {
  name: '${projectName}-vnet'
  scope: rg
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
  scope: rg
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
  scope: rg
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
  scope: rg
  params: {
    appPlanName: appPlanName
    appServiceName: appServiceName
    appSubnetId: vnet.outputs.appSubnetId
    location: location
    appSettings: {
      SQL_CONNECTIONSTRING: ''
      CACHE_CONNECTIONSTRING: ''
      STORAGE_CONNECTIONSTRING: ''
    }
  }
}

module cache 'modules/cache.bicep' = {
  dependsOn: [
    vnet
  ]
  name: '${projectName}-cache'
  scope: rg
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
  scope: rg
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
  scope: rg
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
  scope: rg
  params: {
    frontDoorEndpointName: 'storage-${uniqueString(rg.id)}'
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
  scope: rg
  params: {
    frontDoorEndpointName: 'app-${uniqueString(rg.id)}'
    frontDoorProfileName: frontDoorProfileName
    frontDoorOriginName: 'app-origin'
    originHostName: appOriginHostName
    privateEndpointLocation: location
    privateEndpointResourceId: appServiceId
    privateLinkResourceType: appOriginHostType
  }
}
