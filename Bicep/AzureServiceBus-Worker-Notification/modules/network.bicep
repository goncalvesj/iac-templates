param location string = resourceGroup().location

// Spoke VNET Settings
param spokeVnetName string = ''
param spokeVnetAddressPrefix string = ''
param aksSubnetName string = ''
param aksSubnetAddress string = ''
param aciSubnetName string = ''
param aciSubnetAddress string = ''

// Create Spoke
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetAddress
        }
      }
      {
        name: aciSubnetName
        properties: {
          addressPrefix: aciSubnetAddress
        }
      }
    ]
  }
}

output aksSubnetId string = '${vnet.id}/subnets/${aksSubnetName}'
output aciSubnetId string = '${vnet.id}/subnets/${aciSubnetName}'
