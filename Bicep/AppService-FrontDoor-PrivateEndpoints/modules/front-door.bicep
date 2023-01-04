param frontDoorSkuName string = 'Premium_AzureFrontDoor'
param frontDoorProfileName string = ''

resource frontDoorProfile 'Microsoft.Cdn/profiles@2022-05-01-preview' = {
  name: frontDoorProfileName
  location: 'global'
  tags: {
  }
  sku: {
    name: frontDoorSkuName
  }
  properties: {
    originResponseTimeoutSeconds: 60
    extendedProperties: {
    }
  }
}
