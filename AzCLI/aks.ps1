$REGION_NAME = "northeurope"
$RESOURCE_GROUP = "RG-AKS"
$SUBNET_NAME = "aks-subnet"
$VNET_NAME = "aks-vnet"
$AKS_CLUSTER_NAME = "goncalvesj-aks"

# az group create `
#     --name $RESOURCE_GROUP `
#     --location $REGION_NAME

# az network vnet create `
#     --resource-group $RESOURCE_GROUP `
#     --location $REGION_NAME `
#     --name $VNET_NAME `
#     --address-prefixes 10.0.0.0/8 `
#     --subnet-name $SUBNET_NAME `
#     --subnet-prefixes 10.240.0.0/16

# $VNET = $(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET_NAME --query "id" --output tsv)
$SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

$VERSION = $(az aks get-versions `
        --location $REGION_NAME `
        --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' `
        --output tsv)

$VERSION
$SUBNET_ID

# az aks create `
#     --resource-group $RESOURCE_GROUP `
#     --name $AKS_CLUSTER_NAME `
#     --vm-set-type "VirtualMachineScaleSets" `
#     --node-count 1 `
#     --node-vm-size "Standard_B2s" `
#     --load-balancer-sku "standard" `
#     --location $REGION_NAME `
#     --kubernetes-version $VERSION `
#     --network-plugin azure `
#     --vnet-subnet-id $SUBNET_ID `
#     --service-cidr 10.2.0.0/24 `
#     --dns-service-ip 10.2.0.10 `
#     --docker-bridge-address 172.17.0.1/16 `
#     --generate-ssh-keys `
#     --enable-managed-identity

# az aks get-credentials `
# --resource-group $RESOURCE_GROUP `
# --name $AKS_CLUSTER_NAME