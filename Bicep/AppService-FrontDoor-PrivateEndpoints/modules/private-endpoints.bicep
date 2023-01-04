param location string = resourceGroup().location

param subnetId string = ''
param virtualNetworkId string = ''

param privateEndpointName string = ''
param privateDnsZoneName string = ''
param resourceId string = ''
param privateLinkResourceType string = ''

var peName = '${privateEndpointName}-pe'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: peName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: peName
        properties: {
          groupIds: [
            privateLinkResourceType
          ]
          privateLinkServiceId: resourceId
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: privateEndpoint.name
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

resource blobPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZone.name}/${uniqueString(resourceId)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}
