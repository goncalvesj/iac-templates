param name string = ''
param location string = resourceGroup().location
param keyVaultName string = ''

var connectionStringName = 'AzureSignalRConnectionString'

resource signalr 'Microsoft.SignalRService/signalR@2022-02-01' = {
  sku: {
    name: 'Free_F1'
    tier: 'Free'
    capacity: 1
  }
  properties: {
    tls: {
      clientCertEnabled: false
    }
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
        properties: {
        }
      }
      {
        flag: 'EnableConnectivityLogs'
        value: 'True'
        properties: {
        }
      }
    ]
    cors: {
      allowedOrigins: [
        '*'
      ]
    }
    upstream: {
    }
    networkACLs: {
      defaultAction: 'Deny'
      publicNetwork: {
        allow: [
          'ServerConnection'
          'ClientConnection'
          'RESTAPI'
          'Trace'
        ]
      }
      privateEndpoints: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    disableAadAuth: false
  }
  kind: 'SignalR'
  location: location
  tags: {
  }
  name: name
}

module signalRConnectionString 'key-vault-secret.bicep' = {
  name: '${name}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: connectionStringName
    secretValue: signalr.listKeys().primaryConnectionString
  }
}
