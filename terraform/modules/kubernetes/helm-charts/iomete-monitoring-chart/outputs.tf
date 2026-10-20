output "grafana_admin_password" {
  description = "The password of the Grafana admin user"
  value       = random_password.grafana_admin_password.result
  sensitive   = true
}
