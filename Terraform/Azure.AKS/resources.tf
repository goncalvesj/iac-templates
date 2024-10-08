terraform {
  backend "azurerm" {
    resource_group_name  = "RG-Storage"
    storage_account_name = "goncalvesjtfbackends"
    container_name       = "tfstate"
    key                  = "azureaks.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "~> 2.5.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "RG-AKS"
  location = "North Europe"
}

resource "azurerm_kubernetes_cluster" "cluster1" {
  name                = "goncalvesj-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = "rg-aks"
  dns_prefix          = "goncalvesj-aks-dns"
  kubernetes_version  = "1.15.11"

  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.cluster1.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.cluster1.kube_config_raw
}
