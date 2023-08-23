param name string
param location string = resourceGroup().location
param tags object = {}

// Reference Properties
param appServicePlanId string

// Microsoft.Web/sites Properties
param kind string = 'app,linux'

// Microsoft.Web/sites/config
param alwaysOn bool = true
param appCommandLine string = ''
param appSettings object = {}
param authSettings object = {}
param clientAffinityEnabled bool = false
param clientCertEnabled bool = false
param functionAppScaleLimit int = -1
param linuxFxVersion string
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param use32BitWorkerProcess bool = false
param ftpsState string = 'FtpsOnly'
param healthCheckPath string = ''

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      appCommandLine: appCommandLine
      numberOfWorkers: numberOfWorkers != -1 ? numberOfWorkers : null
      minimumElasticInstanceCount: minimumElasticInstanceCount != -1 ? minimumElasticInstanceCount : null
      use32BitWorkerProcess: use32BitWorkerProcess
      functionAppScaleLimit: functionAppScaleLimit != -1 ? functionAppScaleLimit : null
      healthCheckPath: healthCheckPath
      minTlsVersion: '1.2'
    }
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: true
    clientCertEnabled: clientCertEnabled
  }

  identity: {
    type: 'SystemAssigned'
  }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: appSettings
  }

  resource configAuthSettings 'config' = {
    name: 'authsettingsV2'
    properties: authSettings
  }
}
