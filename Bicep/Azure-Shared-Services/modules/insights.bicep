param location string = resourceGroup().location
param workspaceResourceId string

param appInsightsName string


resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'other'
  properties: {
    Application_Type: 'other'
    WorkspaceResourceId: workspaceResourceId
  }
}

output appInsightsId string = appInsights.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
