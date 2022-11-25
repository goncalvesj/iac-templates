param location string = resourceGroup().location
param workspaceResourceId string = ''
param keyVaultName string = ''

param appInsightsName string = ''

var connectionStringName = 'InsightsInstrumentationKey'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location  
  kind: 'other'
  properties: {
    Application_Type: 'other'
    WorkspaceResourceId: workspaceResourceId
  }
}

module storageConnectionString 'key-vault-secret.bicep' = {
  name: '${appInsightsName}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: connectionStringName
    secretValue: appInsights.properties.ConnectionString
  }
}
