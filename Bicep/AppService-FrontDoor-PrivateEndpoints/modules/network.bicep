param location string = resourceGroup().location

// Spoke VNET Settings
param vnetName string = 'JPRG-LZ-3-Spoke'
param vnetAddressPrefix string = '10.2.0.0/16'
param appSubnetName string = 'APP-Subnet'
param appSubnetAddress string = '10.2.1.0/24'
param storageSubnetName string = 'STORAGE-Subnet'
param storageSubnetAddress string = '10.2.0.0/24'
param kvSubnetName string = 'KV-Subnet'
param kvSubnetAddress string = '10.2.2.0/29'
param cacheSubnetName string = 'REDIS-Subnet'
param cacheSubnetAddress string = '10.2.3.0/29'
param sqlSubnetName string = 'SQL-Subnet'
param sqlSubnetAddress string = '10.2.4.0/29'

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  tags: {
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddress
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: storageSubnetName
        properties: {
          addressPrefix: storageSubnetAddress
        }
      }
      {
        name: kvSubnetName
        properties: {
          addressPrefix: kvSubnetAddress
        }
      }
      {
        name: cacheSubnetName
        properties: {
          addressPrefix: cacheSubnetAddress
        }
      }
      {
        name: sqlSubnetName
        properties: {
          addressPrefix: sqlSubnetAddress
        }
      }
    ]
    enableDdosProtection: false
  }
}

output vnetId string = vnet.id
output appSubnetId string = '${vnet.id}/subnets/${appSubnetName}'
output kvSubnetId string = '${vnet.id}/subnets/${kvSubnetName}'
output storageSubnetId string = '${vnet.id}/subnets/${storageSubnetName}'
output cacheSubnetId string = '${vnet.id}/subnets/${cacheSubnetName}'
output sqlSubnetId string = '${vnet.id}/subnets/${sqlSubnetName}'
