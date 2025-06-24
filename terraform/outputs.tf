output "kube_config" {
  description = "Raw kubeconfig to be used with kubectl"
  value       = module.kubernetes_cluster.kube_config
  sensitive   = true
}

output "minio_admin_password" {
  description = "The minio adminstrator user account password"
  value     = module.minio.root_password
  sensitive = true
}

output "postgresql_admin_password" {
  description = "The postgresql admin user account password"
  value     = module.postgresql_server.administrator_password
  sensitive = true
}

output "postgresql_user_password" {
  description = "The postgresql IOMETE application user account password"
  value     = module.postgresql_user.password
  sensitive = true
}

output "iomete_console_admin_password" {
  description = "The admin password to login to the IOMETE web console"
  value     = module.dataplane-enterprise.iomete_admin_password
  sensitive = true
}

output "truststore_password" {
  description = "The password for the truststore containing the relevant certificates used by the applications"
  value = module.dataplane-enterprise.truststore_password
  sensitive = true
}