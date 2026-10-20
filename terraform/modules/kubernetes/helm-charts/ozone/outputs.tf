output "api_endpoint" {
  description = "Ozone S3 Gateway endpoint within the cluster"
  value       = local.s3_endpoint
}

output "bucket_name" {
  description = "Bucket created for the lakehouse"
  value       = var.bucket_name
}

output "access_key" {
  description = "S3 access key for the Ozone S3 Gateway"
  value       = var.s3_access_key
}

output "secret_key" {
  description = "S3 secret key for the Ozone S3 Gateway"
  value       = random_password.s3_secret_key.result
  sensitive   = true
}

output "recon_service_name" {
  description = "Service of the Recon web UI (port 9888), when Recon is enabled"
  value       = var.recon_enabled ? "${var.release_name}-recon" : null
}
