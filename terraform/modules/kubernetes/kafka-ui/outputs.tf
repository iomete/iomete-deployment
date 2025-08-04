output "service_name" {
  description = "Name of the Kafka UI service"
  value       = kubernetes_service.kafka_ui.metadata[0].name
}

output "namespace" {
  description = "Namespace where Kafka UI is deployed"
  value       = var.namespace
}

output "port" {
  description = "Port where Kafka UI is available"
  value       = 8080
}