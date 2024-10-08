provider "azurerm" {
  features {
  }
  use_msi         = false
  use_cli         = true
  use_oidc        = false
  subscription_id = "CHANGEME"
  environment     = "public"
}
provider "azapi" {
  use_msi         = false
  use_cli         = true
  use_oidc        = false
  subscription_id = "CHANGEME"
  environment     = "public"
}
terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74"
    }
    azapi = {
      source = "azure/azapi"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
