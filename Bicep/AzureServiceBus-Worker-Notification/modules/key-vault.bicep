param keyVaultName string = ''
param location string = resourceGroup().location

param tenantId string = subscription().tenantId

param objectId string = ''

param keysPermissions array = [
  'list'
]

param secretsPermissions array = [
  'all'
]

param skuName string = 'standard'

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}
