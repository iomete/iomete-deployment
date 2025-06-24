variable "resource_group_name" {
  description = "Name of the resource group for the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "(Optional) DNS prefix for the AKS cluster"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "(Optional) Kubernetes version to use"
  type        = string
  default     = null  # Will use the latest version available as default
}

variable "min_number_of_nodes" {
  description = "(Optional) Minimum amount of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "max_number_of_nodes" {
  description = "(Optional) Maximum amount of nodes in the default node pool"
  type        = number
  default     = 6
}

variable "max_number_of_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent"
  type        = number
  default     = 110
}

variable "vm_size" {
  description = "(Optional) Size of the VM for the nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "tags" {
  description = "(Optional) Tags to apply to all resources"
  type = map(string)
  default = {}
}
