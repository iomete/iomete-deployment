variable "namespace" {
  description = "Kubernetes namespace to deploy Kafka UI in"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kafka cluster to connect to"
  type        = string
}

variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers"
  type        = string
}