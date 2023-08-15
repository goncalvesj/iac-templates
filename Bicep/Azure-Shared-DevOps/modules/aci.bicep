param location string = resourceGroup().location
param acrName string
param acrResourceGroup string

param aciName string
param adoOrgUrl string
param adoAgentImage string
@secure()
param adoPatToken string

resource jprgacr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
  scope: resourceGroup(acrResourceGroup)
}
// Uses Spot Instances with have limitations. https://learn.microsoft.com/en-us/azure/container-instances/container-instances-spot-containers-overview
resource aci 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: aciName
  location: location
  properties: {
    imageRegistryCredentials: [
      {
        server: jprgacr.properties.loginServer
        username: jprgacr.name
        password: jprgacr.listCredentials().passwords[0].value
      }
    ]
    sku: 'Standard'
    priority: 'Spot'
    containers: [
      {
        name: aciName
        properties: {
          environmentVariables: [
            {
              name: 'AZP_AGENT_NAME'
              value: aciName
            }
            {
              name: 'AZP_URL'
              value: adoOrgUrl
            }
            {
              name: 'AZP_TOKEN'
              secureValue: adoPatToken
            }
          ]
          image: adoAgentImage
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
  }
}
