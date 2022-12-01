param location string = resourceGroup().location
param tenantId string = subscription().tenantId

param projectName string = 'lz1'

// Spoke VNET Settings
param spokeVnetName string =  toUpper('JPRG-${projectName}-Spoke')
param spokeVnetAddressPrefix string = '10.1.0.0/16'
param aksSubnetName string = 'AKS-Subnet'
param aksSubnetAddress string = '10.1.1.0/24'
param aciSubnetName string = 'ACI-Subnet'
param aciSubnetAddress string = '10.2.0.0/24'

// Storage Settings
param storageAccountName string = toLower('${projectName}storage')
param storageAccountType string = 'Standard_LRS'
param inputBlobContainerName string = 'input'
param outputBlobContainerName string = 'output'

// Service Bus Settings
param serviceBusName string = toLower('${projectName}servicebus')
param serviceBusSku string = 'Basic'
param inputQueueName string = 'input-queue'
param outputQueueName string = 'output-queue'

// Event Grid Settings
param eventGridTopicName string = toLower('${projectName}eventgridtopic')

// Insights Settings, needs existing Log Analytics Workspace
param appInsightsName string = toLower('${projectName}appinsights')
param workspaceResourceId string = 'CHANGE_ME'

// AKS Settings
param clusterName string = toLower('${projectName}-aks-cluster')
param nodeCount int = 2
param vmSize string = 'Standard_B2s'
param userVmSize string = 'Standard_D2s_v3'
// Container Registry Settings, needs existing ACR in a separate resource group
param acrName string = ''
param acrRgName string = ''
param acrRoleId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

// Azure AAD Group ID for AKS RBAC
param aadAdminGroupId string = 'CHANGE_ME'
param laWorkspaceId string = workspaceResourceId

// Client App Params, location not yet available in NEU
param clientAppName string = toLower('${projectName}-notification-client')
param clientAppLocation string = 'westeurope'

// Comms Services Params
param commsServicesName string = toLower('${projectName}commservices')
param emailServiceName string = toLower('${projectName}emaildomain1')

// SignalR Params
param signalrName string = toLower('${projectName}signalr')

// Function Params
param functionAppName string = toLower('${projectName}functions')
param functionRuntime string = 'dotnet'
param functionStorageAccountType string = 'Standard_LRS'
param functionDestinationEmail string = 'CHANGE_ME' // Email address to send notifications to

// Key Vault Settings
param kvName string = toLower('${projectName}keyvault')

module kv 'modules/key-vault.bicep' = {
  name: '${projectName}-key-vault'
  params: {
    keysPermissions: []
    keyVaultName: kvName
    location: location
    objectId: aks.outputs.clusterPrincipalID
    secretsPermissions: [
      'all'
    ]
    skuName: 'standard'
    tenantId: tenantId    
  }
}

module vnet 'modules/network.bicep' = {
  name: '${projectName}-vnet'
  params: {
    spokeVnetName: spokeVnetName
    location: location
    spokeVnetAddressPrefix: spokeVnetAddressPrefix
    aksSubnetName: aksSubnetName
    aksSubnetAddress: aksSubnetAddress
    aciSubnetName: aciSubnetName
    aciSubnetAddress: aciSubnetAddress
  }
}

module storage 'modules/storage.bicep' = {
  dependsOn: [
    kv
  ]
  name: '${projectName}-storage'
  params: {
    location: location
    accountName: storageAccountName
    inputBlobContainerName: inputBlobContainerName
    outputBlobContainerName: outputBlobContainerName
    skuName: storageAccountType
    keyVaultName: kvName
  }
}

module sbus 'modules/service-bus.bicep' = {
  dependsOn: [
    kv
  ]
  name: '${projectName}-service-bus'
  params: {
    location: location
    inputQueueName: inputQueueName
    outputQueueName: outputQueueName
    serviceBusName: serviceBusName
    sku: serviceBusSku
    keyVaultName: kvName
  }
}

module egrid 'modules/event-grid.bicep' = {
  dependsOn: [
    storage
    sbus
  ]
  name: '${projectName}-event-grid'
  params: {
    location: location
    eventGridTopicName: eventGridTopicName
    inputServiceBusQueueId: sbus.outputs.inputServiceBusQueueId
    outputServiceBusQueueId: sbus.outputs.outputServiceBusQueueId
    storageId: storage.outputs.storageResourceId
  }
}

module insights 'modules/insights.bicep' = {
  dependsOn: [
    kv
  ]
  name: '${projectName}-insights'
  params: {
    location: location
    workspaceResourceId: workspaceResourceId
    appInsightsName: appInsightsName
    keyVaultName: kvName
  }
}

module aks 'modules/aks.bicep' = {
  name: '${projectName}-aks'
  params: {
    location: location
    clusterName: clusterName
    nodeCount: nodeCount
    vmSize: vmSize
    userVmSize: userVmSize
    aadAdminGroupId: aadAdminGroupId
    laWorkspaceId: laWorkspaceId
    aksSubnetId: vnet.outputs.aksSubnetId
    // aciSubnetName: aciSubnetName
    acrName: acrName
    acrRgName: acrRgName
    acrRoleId: acrRoleId
  }
  dependsOn: [
    vnet
  ]
}

// TODO: Works if the Comms Services are to be created but not if they already exist, needs investigation.
module comms 'modules/comm-services.bicep' = {
  dependsOn: [
    kv
  ]
  name: '${projectName}-comms'
  params: {
    commsServicesName: commsServicesName
    emailServiceName: emailServiceName
    keyVaultName: kvName
  }
}

module signalr 'modules/signalr.bicep' = {
  dependsOn: [
    kv
  ]
  name: '${projectName}-signalr'
  params: {
    location: location
    name: signalrName
    keyVaultName: kvName
  }
}

module clientapp 'modules/static-web-app.bicep' = {
  name: '${projectName}-client-app'
  params: {
    name: clientAppName
    location: clientAppLocation
  }
}

module functions 'modules/functions.bicep' = {
  dependsOn: [
    signalr
    clientapp
    sbus
    comms
  ]
  name: '${projectName}-functions'
  params: {
    appInsightsLocation: location
    appName: functionAppName
    clientAppUrl: clientapp.outputs.staticSiteUrl
    signalRName: signalrName
    commsServiceName: commsServicesName
    serviceBusRuleId: sbus.outputs.functionQueueRuleId
    commsServiceSender: comms.outputs.mailFromSenderDomain
    destinationEmail: functionDestinationEmail
    location: location
    runtime: functionRuntime
    storageAccountType: functionStorageAccountType
  }
}
