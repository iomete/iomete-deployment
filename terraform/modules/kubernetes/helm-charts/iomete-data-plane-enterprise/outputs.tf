output "iomete_admin_password" {
  description = "The temporary password for the admin user to log in to the IOMETE console"
  value       = random_password.iomete_admin_password.result
  sensitive   = true
}
