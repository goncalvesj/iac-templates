terraform {
  backend "azurerm" {
    resource_group_name  = "RG-Storage"
    storage_account_name = "goncalvesjtfbackends"
    container_name       = "tfstate"
    key                  = "azureappservicedocker.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "RG-Containers"
  location = "North Europe"
}

resource "azurerm_app_service_plan" "example" {
  name                = "RG-AppPlan-Linux"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "dockerapp" {
  name                = "goncalvesj-ncngb2c"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id
  https_only          = true

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  site_config {
    linux_fx_version = "DOCKER|goncalvesj/netcore-angular-b2c:dev"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}