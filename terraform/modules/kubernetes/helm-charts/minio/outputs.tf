output "api_endpoint" {
  description = "Minio API endpoint within the cluster"
  value       = "https://${kubernetes_service.minio_service.metadata[0].name}.${kubernetes_service.minio_service.metadata[0].namespace}.svc.cluster.local:9000"
}

output "root_user" {
  description = "Minio admin username"
  value       = var.minio_root_user
}

output "root_password" {
  description = "Minio admin password"
  value       = random_password.minio_root_password.result
  sensitive   = true
}

output "cert_pem" {
  description = "Minio root CA certificate"
  value       = tls_self_signed_cert.ca_cert.cert_pem
}