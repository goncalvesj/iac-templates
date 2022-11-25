$ManagementSubscriptionId="CHANGE_ME"
$BicepFile = "main.bicep"
$ParamsFile = "main.parameters.json"
$Location = "northeurope"
$LZ1RG = "JPRG-ALZ-LZ-1"

az account set --subscription $ManagementSubscriptionId

# Create Resource Group - optional when using an existing resource group
az group create --name $LZ1RG --location $Location

# Deploy Module 
az deployment group create `
  --template-file $BicepFile `
  --parameters $ParamsFile `
  --resource-group $LZ1RG

# Add KEDA Integration to AKS
$AKS=$(az aks list -g $LZ1RG --query "[0].name" -o tsv)
az aks update --resource-group $LZ1RG --name $AKS --enable-keda

# Get AKS Credentials
az aks get-credentials --resource-group $LZ1RG --name $AKS

# --- K8s Operations ---

# Create K8s Namespace
$K8sNamespace = "keda-dotnet-sample"
kubectl create namespace $K8sNamespace

# Create KEDA Secret
$QueueName = "input-queue"
$SBUS=$(az servicebus namespace list -g $LZ1RG --query "[0].name" -o tsv)

$KEDACONNSTRING=$(az servicebus queue authorization-rule keys list -g $LZ1RG --namespace-name $SBUS --queue-name $QueueName -n keda-monitor --query primaryConnectionString -o tsv)
kubectl create secret -n $K8sNamespace generic keda-monitor-secret --from-literal servicebus-connectionstring="$KEDACONNSTRING"