param location string = resourceGroup().location
param accountName string = ''
param skuName string = 'Standard_LRS'
param inputBlobContainerName string = 'input'
param outputBlobContainerName string = 'output'
param keyVaultName string = ''

var connectionStringName = 'StorageConnectionString'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {}

  resource defaultBlobService 'blobServices' existing = {
    name: 'default'
  }
}

resource inputBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: inputBlobContainerName
  parent: storageAccount::defaultBlobService
  properties:{
    publicAccess: 'None'
  }
}

resource outputBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: outputBlobContainerName
  parent: storageAccount::defaultBlobService
  properties:{
    publicAccess: 'None'
  }
}

output blobEndpointHostName string = replace(replace(storageAccount.properties.primaryEndpoints.blob, 'https://', ''), '/', '')
output storageResourceId string = storageAccount.id

module commsConnectionString 'key-vault-secret.bicep' = {
  name: '${accountName}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: connectionStringName
    secretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
  }
}
