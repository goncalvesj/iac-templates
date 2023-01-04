param location string = resourceGroup().location
param name string = ''
param subnetId string = ''
param virtualNetworkId string = ''

var privateDnsZoneName = 'privatelink.redis.cache.windows.net'

resource cache 'Microsoft.Cache/redis@2022-06-01' = {
  location: location
  name: name
  properties: {
    redisVersion: '6.0'
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
  }
}

module pe 'private-endpoints.bicep' = {
  name: '${name}-pe'
  params: {
    location: location
    privateDnsZoneName: privateDnsZoneName
    privateEndpointName: name
    privateLinkResourceType: 'redisCache'
    resourceId: cache.id
    subnetId: subnetId
    virtualNetworkId: virtualNetworkId
  }
}
