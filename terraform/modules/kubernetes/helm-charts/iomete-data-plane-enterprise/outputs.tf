output "iomete_admin_password" {
  description = "The password for the admin user to login to the iomete console"
  value     = random_password.iomete_admin_password.result
  sensitive = true
}

output "truststore_password" {
  description = "The password for the truststore in the kubernetes secret with relevant certificates used by the applications"
  value = random_password.truststore_password.result
  sensitive = true
}