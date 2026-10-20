variable "azure_subscription_id" {
  description = "Azure subscription ID to create the environment in"
  type        = string
}

variable "azure_tenant_id" {
  description = "(Optional) Azure tenant ID. Defaults to the tenant of your Azure CLI login"
  type        = string
  default     = null
}

variable "azure_region" {
  description = "The Azure region to create the environment in, for example germanywestcentral"
  type        = string
}

variable "environment_name" {
  description = "(Optional) Name of the environment. Used for the resource group and as a prefix for resource names"
  type        = string
  default     = "iomete-sample"
}

variable "iomete_admin_email" {
  description = "Email of the IOMETE console admin user"
  type        = string
}

variable "iomete_dataplane_enterprise_chart_version" {
  description = "(Optional) Version of the IOMETE data plane enterprise Helm chart"
  type        = string
  default     = "4.0.1"
}

variable "iomete_monitoring_chart_version" {
  description = "(Optional) Version of the IOMETE monitoring Helm chart"
  type        = string
  default     = "3.0.1"
}

variable "postgresql_sku_name" {
  description = "(Optional) SKU of the Azure PostgreSQL Flexible Server. IOMETE opens many connections, so avoid the burstable B1ms tier"
  type        = string
  default     = "GP_Standard_D2ds_v5"
}

variable "ozone_datanode_storage_size" {
  description = "(Optional) Size of the disk that holds all lakehouse data in Apache Ozone"
  type        = string
  default     = "100Gi"
}

variable "ozone_recon_enabled" {
  description = "(Optional) Install Recon, Apache Ozone's web UI"
  type        = bool
  default     = true
}

variable "kubernetes_vm_size" {
  description = "(Optional) VM size of the AKS nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "kubernetes_min_nodes" {
  description = "(Optional) Minimum number of AKS nodes"
  type        = number
  default     = 1
}

variable "kubernetes_max_nodes" {
  description = "(Optional) Maximum number of AKS nodes the autoscaler may add"
  type        = number
  default     = 6
}

variable "enable_monitoring" {
  description = "(Optional) Install the IOMETE monitoring chart (Prometheus and Grafana)"
  type        = bool
  default     = true
}

variable "iomete_extra_values" {
  description = "(Optional) Extra top-level IOMETE chart values, merged over the ones Terraform sets, for example services resource requests"
  type        = any
  default     = {}
}
