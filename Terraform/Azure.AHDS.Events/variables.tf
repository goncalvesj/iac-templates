variable "location" {
  description = "The location where the resources will be created"
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "CHANGEME"
}

variable "ahds_resource_id" {
  description = "The ID of the Azure Healthcare Data Service"
  type        = string
  default     = "CHANGEME"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    project     = "ahds events"
  }
  description = <<DESCRIPTION
  Defaults to `{}`. A mapping of tags to assign to the resource. These tags will propagate to any child resource unless overriden when creating the child resource

  Example Inputs:
  ```hcl
  tags = {
    environment = "testing"
  }
  ```
  DESCRIPTION
}
