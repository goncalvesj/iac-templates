param commsServicesName string = ''
param emailServiceName string = ''
param keyVaultName string = ''

var connectionStringName = 'CommsServiceConnectionString'

// Throws error if service already exists, needs workaround
resource lzemailservice 'Microsoft.Communication/emailServices@2022-07-01-preview' = {
  name: emailServiceName
  location: 'global'
  tags: {
  }
  properties: {
    dataLocation: 'United States'
  }
}

resource lzManagedDomain 'Microsoft.Communication/emailServices/domains@2022-07-01-preview' = {
  name: 'AzureManagedDomain'
  location: 'global'
  parent: lzemailservice
  properties: {
    domainManagement: 'AzureManaged'
    validSenderUsernames: {
      DoNotReply: 'DoNotReply'
    }
    userEngagementTracking: 'Disabled'
  }
}

resource lzcommservices 'Microsoft.Communication/communicationServices@2022-07-01-preview' = {
  name: commsServicesName
  location: 'global'
  tags: {
  }
  properties: {
    dataLocation: 'United States'
    linkedDomains: [
      lzManagedDomain.id
    ]
  }
}

output mailFromSenderDomain string = lzManagedDomain.properties.mailFromSenderDomain

module commsConnectionString 'key-vault-secret.bicep' = {
  name: '${commsServicesName}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: connectionStringName
    secretValue: lzcommservices.listKeys().primaryConnectionString
  }
}
