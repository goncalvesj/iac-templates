targetScope = 'subscription'
param location string = 'westeurope'
param name string = 'ALZ-DevOps'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: location
}
