locals {
  # additional tags that can be used for tracking/tagging/attribution/etc
  tags = {
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.environment_name
  location = var.azure_region
  tags     = local.tags
}

module "kubernetes_cluster" {
  source = "./modules/kubernetes/cluster/azure"

  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  cluster_name        = "${var.environment_name}-aks-cluster"
  vm_size             = var.kubernetes_vm_size
  min_number_of_nodes = var.kubernetes_min_nodes
  max_number_of_nodes = var.kubernetes_max_nodes

  tags = local.tags
}

module "postgresql_server" {
  source = "./modules/postgresql/server/azure"

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  server_name    = "${var.environment_name}-postgresql"
  sku_name       = var.postgresql_sku_name
  admin_username = "iomete_admin"

  tags = local.tags
}

module "postgresql_user" {
  source = "./modules/postgresql/users"

  # enforce waiting for firewall rules that need to be in place to
  # allow your machine to connect to create the user
  user_creation_depends_on = [module.postgresql_server.firewall_ip_range]

  # user to create
  username = "iomete_user"
}

module "kubernetes_infra_namespace" {
  depends_on = [module.kubernetes_cluster]
  source     = "./modules/kubernetes/namespace"

  namespace = "infra"
}

module "ozone" {
  source = "./modules/kubernetes/helm-charts/ozone"

  kubernetes_storage_provisioner = "disk.csi.azure.com"
  namespace                      = module.kubernetes_infra_namespace.namespace_name
  datanode_storage_size          = var.ozone_datanode_storage_size
  recon_enabled                  = var.ozone_recon_enabled
}

module "iomete_control_plane_namespace" {
  depends_on = [module.kubernetes_cluster]
  source     = "./modules/kubernetes/namespace"

  namespace = "iomete-system"
  labels = {
    "iomete.com/managed" = "true"
  }
}

module "dataplane-enterprise" {
  source = "./modules/kubernetes/helm-charts/iomete-data-plane-enterprise"

  # The lakehouse bucket must exist before IOMETE starts. The whole PostgreSQL module too, not
  # just the server: changing max_connections restarts the server, and IOMETE's database setup
  # job fails with "Connection refused" if it runs during that restart.
  depends_on = [module.ozone, module.postgresql_server, module.postgresql_user]

  # chart version
  iomete_dataplane_enterprise_chart_version = var.iomete_dataplane_enterprise_chart_version

  # control plane namespace
  namespace = module.iomete_control_plane_namespace.namespace_name

  admin_email = var.iomete_admin_email

  # Apache Ozone through its S3 Gateway
  storage = {
    bucketName = module.ozone.bucket_name
    type       = "s3_compatible"
    s3CompatibleSettings = {
      endpoint  = module.ozone.api_endpoint
      accessKey = module.ozone.access_key
      secretKey = module.ozone.secret_key
    }
  }

  # postgresql connection details
  postgresql_host           = module.postgresql_server.host
  postgresql_port           = module.postgresql_server.port
  postgresql_user           = module.postgresql_user.username
  postgresql_password       = module.postgresql_user.password
  postgresql_admin_user     = module.postgresql_server.administrator_username
  postgresql_admin_password = module.postgresql_server.administrator_password

  # any other chart values, for example smaller resource requests
  extra_values = var.iomete_extra_values
}

module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./modules/kubernetes/helm-charts/iomete-monitoring-chart"

  iomete_monitoring_chart_version = var.iomete_monitoring_chart_version

  # install monitoring in control-plane as well
  control_plane_namespace = module.iomete_control_plane_namespace.namespace_name
  monitoring_namespace    = module.iomete_control_plane_namespace.namespace_name

  # postgresql connection details
  postgresql_host     = module.postgresql_server.host
  postgresql_port     = module.postgresql_server.port
  postgresql_user     = module.postgresql_user.username
  postgresql_password = module.postgresql_user.password
}
