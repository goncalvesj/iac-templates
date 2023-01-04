param location string = resourceGroup().location
param tenantId string = subscription().tenantId

param keyVaultName string = ''

param objectId string = ''

param keysPermissions array = [
  'list'
]

#disable-next-line outputs-should-not-contain-secrets
param secretsPermissions array = [
  'all'
]

param skuName string = 'standard'

param subnetId string = ''
param virtualNetworkId string = ''

var privateDnsZoneName = 'privatelink.vaultcore.azure.net'

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
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

module pe 'private-endpoints.bicep' = {
  name: '${keyVaultName}-pe'
  params: {
    location: location
    privateDnsZoneName: privateDnsZoneName
    privateEndpointName: keyVaultName
    privateLinkResourceType: 'vault'
    resourceId: kv.id
    subnetId: subnetId
    virtualNetworkId: virtualNetworkId
  }
}
