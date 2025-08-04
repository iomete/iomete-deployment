output "deployment_name" {
  description = "Name of the Kafka data producer deployment"
  value       = kubernetes_deployment.kafka_data_producer.metadata[0].name
}

output "namespace" {
  description = "Namespace where Kafka data producer is deployed"
  value       = var.namespace
}

output "topic_name" {
  description = "Kafka topic where data is being produced"
  value       = var.topic_name
}