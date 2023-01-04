$ManagementSubscriptionId="CHANGE_ME"
$BicepFile = "main.bicep"
$ParamsFile = "main.parameters.json" # Generate from main bicep file
$Location = "northeurope"
$LandingZoneRG = "CHANGE_ME"

az account set --subscription $ManagementSubscriptionId

# Create Resource Group - optional when using an existing resource group
az group create --name $LandingZoneRG --location $Location

# Deploy Module 
az deployment group create `
  --template-file $BicepFile `
  --parameters $ParamsFile `
  --resource-group $LandingZoneRG

# TODO
# Approve Private Endpoint Connections created by Front Door