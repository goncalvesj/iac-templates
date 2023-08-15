param frontDoorSkuName string = 'Premium_AzureFrontDoor'
param frontDoorProfileName string = ''

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
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
