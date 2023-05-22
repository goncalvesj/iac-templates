param location string = resourceGroup().location

param projectName string = 'alzdevops'
param deployDevCenter bool = false

// VNET Settings
param vnetName string = toLower('${projectName}spokevnet')
param vnetAddressPrefix string = '10.1.0.0/16'
param subnetList array = [
  {
    name: 'DevBox-Subnet'
    value: '10.1.0.0/24'
    rules: []
  }
  {
    name: 'DevOpsAgents-Subnet'
    value: '10.1.1.0/24'
    rules: []
  }
]

module vnet 'modules/network.bicep' = {
  name: '${projectName}-vnet'
  params: {
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    list: subnetList
    vnetName: vnetName
  }
}

var devopsSubnetId = '${vnet.outputs.vnetId}/subnets/${subnetList[0].name}'

module devcenter 'modules/devcenter.bicep' = if(deployDevCenter) {
  name: '${projectName}-devcenter'
  params: {
    location: location //Not available in NEU
    name: 'JPRG-DevCenter'
    subnetId: devopsSubnetId
  }
}
