$LZRG = "JPRG-ALZ-Shared"
$SubscriptionId = "CHANGE_ME"
$RgBicepFile = "rg.bicep"
$BicepFile = "main.bicep"
$ParamsFile = "main.parameters.json"

az account set --subscription $SubscriptionId

# Deploy Resource Group
az deployment sub create --template-file $RgBicepFile --location northeurope

# Deploy Module 
az deployment group create --template-file $BicepFile --parameters $ParamsFile --resource-group $LZRG