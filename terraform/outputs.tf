output "kube_config" {
  description = "Raw kubeconfig to be used with kubectl"
  value       = module.kubernetes_cluster.kube_config
  sensitive   = true
}

output "iomete_console_admin_password" {
  description = "The temporary admin password to log in to the IOMETE web console"
  value       = module.dataplane-enterprise.iomete_admin_password
  sensitive   = true
}

output "grafana_admin_password" {
  description = "The password of the Grafana admin user"
  value       = one(module.monitoring[*].grafana_admin_password)
  sensitive   = true
}

output "ozone_s3_secret_key" {
  description = "The S3 secret key for the Apache Ozone S3 Gateway"
  value       = module.ozone.secret_key
  sensitive   = true
}

output "postgresql_admin_password" {
  description = "The PostgreSQL admin user account password"
  value       = module.postgresql_server.administrator_password
  sensitive   = true
}

output "postgresql_user_password" {
  description = "The PostgreSQL IOMETE application user account password"
  value       = module.postgresql_user.password
  sensitive   = true
}
