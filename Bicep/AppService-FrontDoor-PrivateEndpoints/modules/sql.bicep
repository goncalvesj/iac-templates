param location string = resourceGroup().location

param sqlServerName string = ''
param sqlAdministratorLogin string = ''
@secure()
param sqlAdministratorLoginPassword string = ''

param subnetId string = ''
param virtualNetworkId string = ''

var databaseName = '${sqlServerName}/sample-db'
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: {
    displayName: sqlServerName
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: databaseName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  tags: {
    displayName: databaseName
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlServer
  ]
}

module pe 'private-endpoints.bicep' = {
  name: '${sqlServerName}-pe'
  params: {
    location: location
    privateDnsZoneName: privateDnsZoneName
    privateEndpointName: sqlServerName
    privateLinkResourceType: 'sqlServer'
    resourceId: sqlServer.id
    subnetId: subnetId
    virtualNetworkId: virtualNetworkId
  }
}
