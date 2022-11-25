param location string = resourceGroup().location

// Spoke VNET Settings
param aksSubnetId string = ''
param aciSubnetName string = ''

// AKS Settings
param clusterName string = ''
param nodeCount int = 2
param vmSize string = 'Standard_B2s'
param userVmSize string = 'Standard_D2s_v3'

param aadAdminGroupId string = ''
param laWorkspaceId string = ''


// Create AKS
resource aks 'Microsoft.ContainerService/managedClusters@2022-07-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      adminGroupObjectIDs: [ aadAdminGroupId ]
    }
    kubernetesVersion: '1.24.6'
    apiServerAccessProfile: {}
    dnsPrefix: clusterName
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidr: '172.16.0.0/22' // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
      dnsServiceIP: '172.16.0.10' // Ip Address for K8s DNS
      dockerBridgeCidr: '172.16.4.1/22' // Used for the default docker0 bridge network that is required when using Docker as the Container Runtime.  Not used by AKS or Docker and is only cluster-routable.  Cluster IP based addresses are allocated from this range.  Can be safely reused in multiple clusters.
    }
    agentPoolProfiles: [
      {
        name: 'systempool1'
        count: 1
        vmSize: vmSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        vnetSubnetID: aksSubnetId
      }
      {
        name: 'jobpool1'
        count: 1
        vmSize: userVmSize
        maxCount: nodeCount
        minCount: 0
        enableAutoScaling: true
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'User'
        vnetSubnetID: aksSubnetId
        scaleSetEvictionPolicy: 'Deallocate'
        nodeLabels: {
          'kubernetes.azure.com/scalesetpriority': 'spot'
          workload: 'jobs'
        }
        nodeTaints: [
          'kubernetes.azure.com/scalesetpriority=spot:NoSchedule'
        ]
      }
    ]
    addonProfiles: {
      azurepolicy: {
        enabled: false
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: laWorkspaceId
        }
      }
      aciConnectorLinux: {
        enabled: true
        config: {
          SubnetName: aciSubnetName
        }
      }     
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
    }
  }
}

output clusterPrincipalID string = aks.properties.identityProfile.kubeletidentity.objectId

param acrName string = ''
param acrRgName string = ''
param acrRoleId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

module registry 'role-assignment.bicep' = {
  name: '${clusterName}-role-assignment'
  scope: resourceGroup(acrRgName)
  params: {
    registryName: acrName
    aksPrincipalId: aks.properties.identityProfile.kubeletidentity.objectId
    roleAcrPull: acrRoleId
  }
}
