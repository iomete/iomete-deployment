resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix != null ? var.dns_prefix : var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    vm_size             = var.vm_size
    auto_scaling_enabled = true
    min_count           = var.min_number_of_nodes
    max_count           = var.max_number_of_nodes
    max_pods            = var.max_number_of_pods
    os_disk_size_gb     = 512
    upgrade_settings {
      # these are Azure default. Added these since without them Terraform module thinks the state is inconsistent
      # and keeps changing them between the defaults and null
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
