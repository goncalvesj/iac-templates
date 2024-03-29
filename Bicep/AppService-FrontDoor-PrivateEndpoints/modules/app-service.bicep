param location string = resourceGroup().location
param appPlanName string = ''
param appServiceName string = ''
param appSubnetId string = ''
param appSettings object = {}

resource appplan 'Microsoft.Web/serverfarms@2022-03-01' = {
  location: location
  name: appPlanName
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appplan.id
    httpsOnly: true
    virtualNetworkSubnetId: appSubnetId
  }
  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: appSettings
  }
}

output appHostName string = app.properties.defaultHostName
output appServiceResourceId string = app.id
