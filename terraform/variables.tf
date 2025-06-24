variable "azure_subscription_id" {
  description = "Azure Subscription Id"
  type        = string
  default     = "" # please provide
}

variable "azure_tenant_id" {
  description = "Azure tenant Id"
  type        = string
  default     = "" # please provide
}

variable "azure_region" {
  description = "The Azure region to spin up the IOMETE cluster in"
  type        = string
  default     = "" # please provide
}

variable "terraform_state_resource_group_name" {
  description = "The name of the resource group in which the Terraform state is stored"
  type        = string
  default     = "terraform-state-rg"
}

variable "terraform_state_storage_account_name" {
  description = "The name of the storage account for the Terraform state files"
  type        = string
  default     = "iomete"
}

variable "terraform_state_container_name" {
  description = "The name of the storage container"
  type        = string
  default     = "tfstate"
}

variable "terraform_state_key" {
  description = "The key for the state files in the storage container"
  type        = string
  default     = "iomete/kubernetes.tfstate"
}
