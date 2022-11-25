param name string = ''
param location string = 'westeurope'


resource lznotificationclient 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'Custom'
    enterpriseGradeCdnStatus: 'Disabled'
  }
  sku: {
    name: 'Free'
    tier: 'Free'
  }
}

output staticSiteUrl string = lznotificationclient.properties.defaultHostname
