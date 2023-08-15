param location string = resourceGroup().location

// Spoke VNET Settings
param vnetName string
param vnetAddressPrefix string
param list array

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = [for item in list: {
  name: '${item.name}-nsg'
  location: location
  properties: {
    securityRules: item.rules
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  dependsOn: [
    nsg
  ]
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for (item, index) in list: {
      name: item.name
      properties: {
        addressPrefix: item.value
        networkSecurityGroup: {
          id: nsg[index].id
        }
      }
    }]
    enableDdosProtection: false
  }
}

output vnetId string = vnet.id
