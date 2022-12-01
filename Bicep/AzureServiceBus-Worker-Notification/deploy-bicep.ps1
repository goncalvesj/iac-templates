$ManagementSubscriptionId="CHANGE_ME"
$BicepFile = "main.bicep"
$ParamsFile = "main.parameters.json" # Generate from main bicep file
$Location = "northeurope"
$LZ1RG = "CHANGE_ME"

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