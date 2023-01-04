param location string = resourceGroup().location
param accountName string = ''
param skuName string = 'Standard_LRS'
param inputBlobContainerName string = 'static-files'

param subnetId string = ''
param virtualNetworkId string = ''

var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    allowBlobPublicAccess: true
    publicNetworkAccess: 'Disabled'
  }

  resource defaultBlobService 'blobServices' existing = {
    name: 'default'
  }
}

resource inputBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: inputBlobContainerName
  parent: storageAccount::defaultBlobService
  properties: {
    publicAccess: 'Blob'
  }
}

module pe 'private-endpoints.bicep' = {
  name: '${accountName}-pe'
  params: {
    location: location
    privateDnsZoneName: blobPrivateDnsZoneName
    privateEndpointName: accountName
    privateLinkResourceType: 'blob'
    resourceId: storageAccount.id
    subnetId: subnetId
    virtualNetworkId: virtualNetworkId
  }
}


output blobEndpointHostName string = replace(replace(storageAccount.properties.primaryEndpoints.blob, 'https://', ''), '/', '')
output storageResourceId string = storageAccount.id


// USE THIS TO CREATE A KEY VAULT SECRET FOR THE STORAGE CONNECTION STRING
// param keyVaultName string = 'lz1keyvault'
// var connectionStringName = 'StorageConnectionString'
// module commsConnectionString 'key-vault-secret.bicep' = {
//   name: '${accountName}-kv-secret'
//   params: {
//     keyVaultName: keyVaultName
//     secretName: connectionStringName
//     secretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
//   }
// }
