output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers for client connections"
  value = {
    plain = "${var.cluster_name}-kafka-bootstrap.${var.namespace}.svc.cluster.local:9092"
    tls   = "${var.cluster_name}-kafka-bootstrap.${var.namespace}.svc.cluster.local:9093"
  }
}

output "kafka_cluster_name" {
  description = "Name of the Kafka cluster"
  value       = var.cluster_name
}

output "kafka_namespace" {
  description = "Namespace where Kafka is deployed"
  value       = var.namespace
}