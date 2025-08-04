output "operator_namespace" {
  description = "The namespace where the Strimzi operator is deployed"
  value       = var.namespace
}

output "operator_version" {
  description = "The version of Strimzi operator deployed"
  value       = var.strimzi_operator_version
}