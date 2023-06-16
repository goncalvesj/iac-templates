targetScope = 'subscription'
param location string = 'northeurope'
param name string = 'JPRG-ALZ-Shared'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: location
}
