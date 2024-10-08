# We need the tenant id for the key vault.
data "azurerm_client_config" "this" {}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source = "Azure/naming/azurerm"
}

resource "azurerm_resource_group" "res-0" {
  location = var.location
  name     = var.resource_group_name
  tags = var.tags
}

### Log Analytics
module "log_analytics_workspace" {
  source                                    = "Azure/avm-res-operationalinsights-workspace/azurerm"
  location                                  = var.location
  resource_group_name                       = var.resource_group_name
  name                                      = module.naming.log_analytics_workspace.name_unique
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = "PerGB2018"
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
  tags = var.tags
}
###

### Virtual Network
module "app-nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  resource_group_name = var.resource_group_name
  name                = module.naming.network_security_group.name_unique
  location            = var.location
  tags = var.tags
}

module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  name                = module.naming.virtual_network.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  subnets = {
    subnet0 = {
      name             = "pe-subnet"
      address_prefixes = ["10.0.5.0/26"]
    }
    subnet1 = {
      name             = "app-subnet"
      address_prefixes = ["10.0.4.0/26"]
      delegation = [{
        name = "Microsoft.Web.serverFarms"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
      nat_gateway = {
        id = module.natgateway.resource_id
      }
      network_security_group = {
        id = module.app-nsg.resource_id
      }
    }
  }

  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      log_groups            = ["allLogs"]
      metric_categories     = []
    }
  }
  tags = var.tags
}
###

### NAT Gateway
module "natgateway" {
  source              = "Azure/avm-res-network-natgateway/azurerm"
  name                = module.naming.nat_gateway.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name

  public_ips = {
    public_ip_1 = {
      name = "nat_gw_pip1"
    }
  }
  tags = var.tags
}
###

### Service Bus
module "servicebus" {
  source                        = "Azure/avm-res-servicebus-namespace/azurerm"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  name                          = module.naming.servicebus_namespace.name_unique
  sku                           = "Premium"
  public_network_access_enabled = false
  network_rule_config = {
    trusted_services_allowed = true
  }
  topics = {
    "hsetopic_1" = {
      name                  = "topic_1"
      max_size_in_megabytes = 1024

      subscriptions = {
        subscription_1 = {
          name               = "patient-created"
          lock_duration      = "PT2M"
          max_delivery_count = 100
          status             = "Active"
        }
      }

    }
    "hsetopic_2" = {
      name                  = "topic_2"
      max_size_in_megabytes = 1024
      
      subscriptions = {
        subscription_1 = {
          name               = "patient-created"
          lock_duration      = "PT2M"
          max_delivery_count = 100
          status             = "Active"
        }
      }
    }
  }
  role_assignments = {
    event_grid_data_sender = {
      principal_id               = azurerm_eventgrid_system_topic.res-7.identity[0].principal_id
      role_definition_id_or_name = "Azure Service Bus Data Sender"
    }
    app_service_data_sender = {
      principal_id               = module.app-service.system_assigned_mi_principal_id
      role_definition_id_or_name = "Azure Service Bus Data Sender"
    }
    app_service_data_receiver = {
      principal_id               = module.app-service.system_assigned_mi_principal_id
      role_definition_id_or_name = "Azure Service Bus Data Receiver"
    }
  }
  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      log_groups            = ["allLogs"]
      metric_categories     = []
    }
  }
  tags = var.tags
}

###

### Event Grid, no AVM modules for Event Grid yet
resource "azurerm_eventgrid_system_topic" "res-7" {
  location               = var.location
  name                   = "patient-created-topic"
  resource_group_name    = var.resource_group_name
  source_arm_resource_id = var.ahds_resource_id
  topic_type             = "Microsoft.HealthcareApis.Workspaces"
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
  depends_on = [
    azurerm_resource_group.res-0
  ]
}

resource "azurerm_eventgrid_system_topic_event_subscription" "res-8" {
  name                                 = "patient-created-subscription"
  resource_group_name                  = var.resource_group_name
  service_bus_topic_endpoint_id        = module.servicebus.resource_topics["topic_1"].id
  system_topic                         = azurerm_eventgrid_system_topic.res-7.name
  event_delivery_schema                = "CloudEventSchemaV1_0"
  included_event_types                 = ["Microsoft.HealthcareApis.FhirResourceCreated"]
  advanced_filtering_on_arrays_enabled = true
  subject_filter {
    subject_begins_with = "patients/" # Needs to be the same as the subject in the event
  }
  delivery_identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_eventgrid_system_topic.res-7,
    azurerm_resource_group.res-0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "eventgrid-topic-diag" {
  name                       = "to-la"
  target_resource_id         = azurerm_eventgrid_system_topic.res-7.id
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

  enabled_log {
    category_group = "allLogs"
  }
}
###

### App Service
module "app-service" {
  source = "Azure/avm-res-web-site/azurerm"

  name                = module.naming.app_service.name_unique
  resource_group_name = var.resource_group_name
  location            = var.location

  kind    = "webapp"
  os_type = "Linux"

  public_network_access_enabled = false

  virtual_network_subnet_id = module.vnet.subnets["subnet1"].resource_id

  create_service_plan = true
  new_service_plan = {
    sku_name               = "B1"
    os_type                = "Linux"
    zone_balancing_enabled = false
    worker_count           = 1
  }

  enable_application_insights = true

  application_insights = {
    name                  = module.naming.application_insights.name_unique
    resource_group_name   = var.resource_group_name
    location              = var.location
    application_type      = "other"
    workspace_resource_id = module.log_analytics_workspace.resource_id
    tags = var.tags
  }

  managed_identities = {
    system_assigned = true
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  site_config = {
    vnet_route_all_enabled = true
    application_stack = {
      dotnet = {
        current_stack  = "dotnet"
        dotnet_version = "8.0"
      }
    }
  }

  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      log_groups            = ["allLogs"]
      metric_categories     = []
    }
  }
  tags = var.tags
}
###

### Key Vault
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

module "keyvault" {
  source                         = "Azure/avm-res-keyvault-vault/azurerm"
  name                           = module.naming.key_vault.name_unique
  enable_telemetry               = false
  location                       = var.location
  resource_group_name            = var.resource_group_name
  tenant_id                      = data.azurerm_client_config.this.tenant_id
  legacy_access_policies_enabled = false
  purge_protection_enabled       = false
  public_network_access_enabled  = false

  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      subnet_resource_id            = module.vnet.subnets["subnet0"].resource_id
    }
  }
  role_assignments = {
    app_service_secret_user = {
      principal_id               = module.app-service.system_assigned_mi_principal_id
      role_definition_id_or_name = "Key Vault Secrets User"
    }
  }
  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      log_groups            = ["allLogs"]
      metric_categories     = []
    }
  }
  tags = var.tags
}
###
