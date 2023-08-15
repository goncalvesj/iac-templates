param location string
param name string
param subnetId string

resource devcenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' = {
  dependsOn: [
    devboxnetwork
  ]
  name: name
  location: location
}

resource devboxnetwork 'Microsoft.DevCenter/networkConnections@2023-01-01-preview' = {
  name: '${name}-Network'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
  }
}

resource devcenterattachednetwork 'Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview' = {
  name: '${name}-Network'
  parent: devcenter
  properties: {
    networkConnectionId: devboxnetwork.id
  }
}

resource devboxproject 'Microsoft.DevCenter/projects@2023-01-01-preview' = {
  name: '${name}-Project'
  location: location
  properties: {
    devCenterId: devcenter.id
  } 
}

resource devboxdefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-01-01-preview' = {
  name: '${name}-Definition'
  parent: devcenter
  location: location
  properties: {
    imageReference: {
      id: '${devcenter.id}/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    }
    sku: {
      name: 'general_a_8c32gb_v1'
    }
    osStorageType: 'ssd_512gb'
  }
}

resource devboxpool 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = {
  name: '${name}-Pool'
  parent: devboxproject
  location: location
  properties: {
    devBoxDefinitionName: devboxdefinition.name
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: devcenterattachednetwork.name
    stopOnDisconnect: {
      gracePeriodMinutes: 60
      status: 'Enabled'
    }
  }
}

resource devboxpoolschedule 'Microsoft.DevCenter/projects/pools/schedules@2023-01-01-preview' = {
  name: 'default'
  parent: devboxpool
  properties: {
    frequency: 'Daily'
    state: 'Enabled'
    type: 'StopDevBox'
    time: '19:00'
    timeZone: 'Europe/Dublin'
  }
}
