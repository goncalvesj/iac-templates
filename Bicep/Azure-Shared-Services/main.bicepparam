using 'main.bicep'

param projectName = 'alzshared'

// VNET Settings
param vnetName = toLower('${projectName}spokevnet')
param vnetAddressPrefix = '10.4.0.0/16'
param subnetList = [
  {
    name: 'APIM-Subnet'
    value: '10.4.1.0/24'
    rules: [
      {
        name: 'AllowHTTP'
        properties: {
          description: 'Allow HTTP'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          description: 'Allow HTTPS'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }        
      }
      {
        name: 'Allow3443Inbound'
        properties: {
          description: 'Allow 3443'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }        
      }
    ]
  }
]

// Insights Settings, needs existing Log Analytics Workspace
param appInsightsName = toLower('${projectName}appinsights')
param logAnalyticsName = 'jprg-alz-log-analytics'
param logAnalyticsResourceGroup = 'jprg-alz-management'

// APIM Settings
param apiManagementName = toLower('${projectName}apim')
param selfHostedGatewayName = toLower('${projectName}apimhostedgateway')

param registryName = 'jprgacr'
