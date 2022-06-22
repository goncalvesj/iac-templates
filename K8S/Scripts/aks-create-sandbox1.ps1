# AKS Public Cluster Example
$REGION_NAME = "northeurope"
$RESOURCE_GROUP = "AKS-Sandbox"
$SUBNET_NAME = "AksSubnet"
$VNET_RG = "VNET-Sandbox"
$VNET_NAME = "vnetsandbox1"
$AKS_CLUSTER_NAME = "SandboxCluster1"

$SUBSCRIPTION_ID = az account show --query id --output tsv
$TENANT_ID = az account show --query tenantId --output tsv
$AAD_GROUP_ID = az ad group show --group "JGoncalves-AdminTeam" --query id -o tsv

$MY_IP = (Invoke-WebRequest -uri "https://api.ipify.org/").Content

az aks create `
    --resource-group $RESOURCE_GROUP `
    --name $AKS_CLUSTER_NAME `
    --vm-set-type "VirtualMachineScaleSets" `
    --node-count 1 `
    --node-vm-size "Standard_B4ms" `
    --location $REGION_NAME `
    --kubernetes-version "1.21.2" `
    --network-plugin "azure" `
    --vnet-subnet-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$VNET_RG/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME" `
    --service-cidr 172.16.0.0/16 `
    --dns-service-ip 172.16.0.10 `
    --docker-bridge-address 172.17.0.1/16 `
    --enable-managed-identity `
    --attach-acr "acrsandbox1" `
    --api-server-authorized-ip-ranges $MY_IP `
    --enable-aad `
    --enable-azure-rbac `
    --aad-admin-group-object-ids $AAD_GROUP_ID `
    --aad-tenant-id $TENANT_ID

az aks get-credentials `
--resource-group $RESOURCE_GROUP `
--name $AKS_CLUSTER_NAME
