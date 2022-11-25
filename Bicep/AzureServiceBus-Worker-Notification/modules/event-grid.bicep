param location string = resourceGroup().location

param eventGridTopicName string = ''
param storageId string = ''
param inputServiceBusQueueId string = 'input'
param outputServiceBusQueueId string = 'output'

resource eventGridTopic 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: eventGridTopicName
  location: location
  properties: {
    source: storageId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource inputEventGridSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {  
  name: 'inputContainer'
  parent: eventGridTopic
  properties: {    
    destination: {
      endpointType: 'ServiceBusQueue'
      properties: {
        resourceId: inputServiceBusQueueId
      }
    }
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      isSubjectCaseSensitive: false
      subjectBeginsWith: '/blobServices/default/containers/input/'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }
}

resource outputEventGridSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: 'outputContainer'
  parent: eventGridTopic
  properties: {
    destination: {
      endpointType: 'ServiceBusQueue'
      properties: {
        resourceId: outputServiceBusQueueId
      }
    }
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      isSubjectCaseSensitive: false
      subjectBeginsWith: '/blobServices/default/containers/output/'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }
}
