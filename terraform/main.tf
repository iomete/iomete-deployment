locals {
  # name for the environment you are creating
  environment = "iomete-sample"

  # vm sizes to be used for k8 and postgresql
  kubernetes_vm_size = "Standard_D16s_v3"
  postgresql_vm_size = "B_Standard_B1ms"

  # chart versions to install
  iomete_dataplane_enterprise_chart_version = "3.10.2"
  iomete_monitoring_chart_version           = "2.2.0"

  # additional tags that can be used for tracking/tagging/attribution/etc
  tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.environment
  location = var.azure_region
  tags     = local.tags
}

module "kubernetes_cluster" {
  source = "./modules/kubernetes/cluster/azure"

  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  cluster_name = "${local.environment}-aks-cluster"
  vm_size      = local.kubernetes_vm_size

  tags = local.tags
}

module "postgresql_server" {
  source = "./modules/postgresql/server/azure"

  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  server_name    = "${local.environment}-postgresql"
  sku_name       = local.postgresql_vm_size
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

  # details to connect to postgresql to execute user creation
  admin_username = module.postgresql_server.administrator_username
  admin_password = module.postgresql_server.administrator_password
  host           = module.postgresql_server.host
  port           = module.postgresql_server.port
}

module "kubernetes_infra_namespace" {
  source    = "./modules/kubernetes/namespace"
  namespace = "infra"
}

module "minio" {
  source = "./modules/kubernetes/helm-charts/minio"

  kubernetes_storage_provisioner = "disk.csi.azure.com"
  namespace                      = module.kubernetes_infra_namespace.namespace_name
  # storage_size                  = "128Gi"
}

module "airflow" {
  count = var.enable_airflow ? 1 : 0

  source = "./modules/kubernetes/helm-charts/airflow"

  namespace = module.kubernetes_infra_namespace.namespace_name

  # PostgreSQL connection details
  postgresql_host     = module.postgresql_server.host
  postgresql_port     = module.postgresql_server.port
  postgresql_username = module.postgresql_user.username
  postgresql_password = module.postgresql_user.password
  postgresql_database = "airflow"

  depends_on = [
    module.kubernetes_cluster,
    module.postgresql_user
  ]
}

module "strimzi_kafka_operator" {
  count = var.enable_kafka ? 1 : 0

  source = "./modules/kubernetes/helm-charts/strimzi-kafka-operator"

  namespace = module.kubernetes_infra_namespace.namespace_name
}

module "kafka_cluster" {
  count = var.enable_kafka ? 1 : 0

  source = "./modules/kubernetes/kafka-cluster"

  namespace           = module.kubernetes_infra_namespace.namespace_name
  cluster_name        = "test-kafka"
  kafka_replicas      = 1
  kafka_version       = "4.0.0"
  operator_dependency = var.enable_kafka ? module.strimzi_kafka_operator[0] : null

  depends_on = [module.strimzi_kafka_operator]
}

module "kafka_ui" {
  count = var.enable_kafka ? 1 : 0

  source = "./modules/kubernetes/kafka-ui"

  namespace               = module.kubernetes_infra_namespace.namespace_name
  cluster_name            = "test-kafka"
  kafka_bootstrap_servers = var.enable_kafka ? module.kafka_cluster[0].kafka_bootstrap_servers.plain : ""

  depends_on = [module.kafka_cluster]
}

module "kafka_data_producer" {
  count = var.enable_kafka ? 1 : 0

  source = "./modules/kubernetes/kafka-data-producer"

  namespace                = module.kubernetes_infra_namespace.namespace_name
  kafka_bootstrap_servers  = var.enable_kafka ? module.kafka_cluster[0].kafka_bootstrap_servers.plain : ""
  topic_name               = "events"
  data_type                = var.kafka_data_type
  message_interval_seconds = 5

  depends_on = [module.kafka_cluster]
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

  # chart version
  iomete_dataplane_enterprise_chart_version = local.iomete_dataplane_enterprise_chart_version

  # control plane namespace
  namespace = module.iomete_control_plane_namespace.namespace_name

  # certificates needed by apps to talk to various external services
  certificates = [module.minio.cert_pem]

  # minio connection details
  minio_uri      = module.minio.api_endpoint
  minio_username = module.minio.root_user
  minio_secret   = module.minio.root_password

  # postgresql connection details
  postgresql_host           = module.postgresql_server.host
  postgresql_port           = module.postgresql_server.port
  postgresql_user           = module.postgresql_user.username
  postgresql_password       = module.postgresql_user.password
  postgresql_admin_user     = module.postgresql_server.administrator_username
  postgresql_admin_password = module.postgresql_server.administrator_password
}

module "monitoring" {
  source = "./modules/kubernetes/helm-charts/iomete-monitoring-chart"

  iomete_monitoring_chart_version = local.iomete_monitoring_chart_version

  # install monitoring in control-plane as well
  control_plane_namespace = module.iomete_control_plane_namespace.namespace_name
  monitoring_namespace    = module.iomete_control_plane_namespace.namespace_name

  # postgresql connection details
  postgresql_host     = module.postgresql_server.host
  postgresql_port     = module.postgresql_server.port
  postgresql_user     = module.postgresql_user.username
  postgresql_password = module.postgresql_user.password
}
