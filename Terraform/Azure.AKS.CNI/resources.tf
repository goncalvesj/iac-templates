provider "azurerm" {
  version = "~> 2.87.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "AKS-Sandbox"
  location = "North Europe"
}

resource "azurerm_resource_group" "vnetrg" {
  name     = "VNET-Sandbox"
  location = "North Europe"
}

resource "azurerm_virtual_network" "sandbox" {
  name                = "vnetsandbox1"
  location            = azurerm_resource_group.vnetrg.location
  resource_group_name = azurerm_resource_group.vnetrg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "sandbox" {
  name                 = "AksSubnet"
  virtual_network_name = azurerm_virtual_network.sandbox.name
  resource_group_name  = azurerm_virtual_network.sandbox.resource_group_name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "cluster1" {
  name                = "SandboxCluster1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = "1.21.2"
  dns_prefix          = "SandboxCluster1-dns"
  api_server_authorized_ip_ranges = "86.45.51.49"


  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "Standard_B4ms"
    vnet_subnet_id = azurerm_subnet.sandbox.id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      azure_rbac_enabled = true
      admin_group_object_ids = [ "value" ]
    }
  }
}
