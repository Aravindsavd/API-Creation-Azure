variable "client_name" {
  description = "Client name used in resource naming and DNS"
  type        = string
}

variable "region" {
  description = "Azure region shortname (eastus2, westuk, anze)"
  type        = string
  validation {
    condition     = contains(["eastus2", "westuk", "anze"], var.region)
    error_message = "Region must be one of: eastus2, westuk, anze."
  }
}

variable "environment" {
  description = "Environment (prd or uat)"
  type        = string
  validation {
    condition     = contains(["prd", "uat"], var.environment)
    error_message = "Environment must be prd or uat."
  }
}

variable "backend_vm_private_ip" {
  description = "Private IP address of the backend VM"
  type        = string
}

variable "rule_priority" {
  description = "Priority for the new routing rule (must be unique; increment from existing highest)"
  type        = number
}
