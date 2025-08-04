variable "azure_subscription_id" {
  description = "Azure Subscription Id"
  type        = string
  default     = "690a44d8-38ef-404d-9403-412ddf34c7ba" # please provide
}

variable "azure_tenant_id" {
  description = "Azure tenant Id"
  type        = string
  default     = "ad3da1d4-c1f5-4e94-9283-3524fa7bbd8c" # please provide
}

variable "azure_region" {
  description = "The Azure region to spin up the IOMETE cluster in"
  type        = string
  default     = "germanywestcentral" # please provide
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

variable "enable_kafka" {
  description = "Enable Kafka cluster deployment with UI and data producer"
  type        = bool
  default     = true
}

variable "kafka_data_type" {
  description = "Type of data to generate in Kafka producer (e-commerce, iot, clickstream)"
  type        = string
  default     = "e-commerce"
  
  validation {
    condition     = contains(["e-commerce", "iot", "clickstream"], var.kafka_data_type)
    error_message = "kafka_data_type must be one of: e-commerce, iot, clickstream"
  }
}
