# AKS Master URI using "$(kubectl cluster-info | awk '/Kubernetes control plane/{print $7}' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g")"
$MASTER_URI="CHANGE_ME"
$RELEASE_NAME="virtual-kubelet"
$NODE_NAME="virtual-kubelet"
# AKS Cluster Resource Group
$LZ1RG = "CHANGE_ME"

# Change to the values defined on the Bicep file
$CLUSTER_SUBNET_RANGE="10.2.1.0/24"
$ACI_SUBNET_RANGE="10.2.0.0/24"
$ACI_SUBNET_NAME="ACI-Subnet"
# AKS Cluster DNS IP, get from AKS Cluster
$KUBE_DNS_IP="172.16.0.10"

# Virtual Kubelet Helm Chart, get link to latest version
helm install $RELEASE_NAME "https://github.com/virtual-kubelet/azure-aci/raw/gh-pages/charts/virtual-kubelet-azure-aci-1.4.7.tgz" `
  --set provider=azure `
  --set providers.azure.targetAKS=true `
  --set providers.azure.masterUri=$MASTER_URI `
  --set providers.azure.vnet.enabled=true `
  --set providers.azure.vnet.vnetResourceGroup=$LZ1RG `
  --set providers.azure.vnet.subnetName=$ACI_SUBNET_NAME `
  --set providers.azure.vnet.subnetCidr=$ACI_SUBNET_RANGE `
  --set providers.azure.vnet.clusterCidr=$CLUSTER_SUBNET_RANGE `
  --set providers.azure.vnet.kubeDnsIp=$KUBE_DNS_IP `
  --set nodeName=$NODE_NAME