$LZRG = "JPRG-ALZ-DevOps"
$SubscriptionId = "CHANGE_ME"
$RgBicepFile = "rg.bicep"
$BicepFile = "main.bicep"
$ParamsFile = "main.bicepparam"

az account set --subscription $SubscriptionId

# Deploy Resource Group
az deployment sub create --template-file $RgBicepFile --location westeurope

# Deploy Module What If
az deployment group what-if --template-file $BicepFile --parameters $ParamsFile --resource-group $LZRG

# Deploy Module
az deployment group create --template-file $BicepFile --parameters $ParamsFile --resource-group $LZRG