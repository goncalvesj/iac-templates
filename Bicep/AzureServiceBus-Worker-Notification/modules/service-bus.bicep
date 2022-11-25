param location string = resourceGroup().location
param serviceBusName string = ''
param sku string = 'Basic'
param inputQueueName string = 'inputqueue'
param outputQueueName string = 'outputqueue'

param keyVaultName string = ''

var workerConnectionStringName = 'WorkerConnectionString'
var kedaConnectionStringName = 'KedaConnectionString'
var functionConnectionStringName = 'EmailQueueRuleConnectionString'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusName
  location: location
  sku: {
    name: sku
  }
}

resource inputServiceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  name: inputQueueName
  parent: serviceBusNamespace
}

resource outputServiceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = {
  name: outputQueueName
  parent: serviceBusNamespace
}

resource workerQueueRule 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2022-01-01-preview' = {
  name: 'worker-consumer'
  parent: inputServiceBusQueue
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource kedaQueueRule 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2022-01-01-preview' = {
  name: 'keda-monitor'
  parent: inputServiceBusQueue
  properties: {
    rights: [
      'Manage'
      'Send'
      'Listen'
    ]
  }
}

resource functionQueueRule 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2022-01-01-preview' = {
  name: 'email-consumer'
  parent: outputServiceBusQueue
  properties: {
    rights: [
      'Listen'
    ]
  }
}

output inputServiceBusQueueId string = inputServiceBusQueue.id
output outputServiceBusQueueId string = outputServiceBusQueue.id
output functionQueueRuleId string = functionQueueRule.id

module workerQueueRuleConnectionString 'key-vault-secret.bicep' = {
  name: '${workerQueueRule.name}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: workerConnectionStringName
    secretValue: workerQueueRule.listKeys().primaryConnectionString
  }
}

module kedaQueueRuleConnectionString 'key-vault-secret.bicep' = {
  name: '${kedaQueueRule.name}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: kedaConnectionStringName
    secretValue: kedaQueueRule.listKeys().primaryConnectionString
  }
}

module emailQueueRuleConnectionString 'key-vault-secret.bicep' = {
  name: '${functionQueueRule.name}-kv-secret'
  params: {
    keyVaultName: keyVaultName
    secretName: functionConnectionStringName
    secretValue: functionQueueRule.listKeys().primaryConnectionString
  }
}
