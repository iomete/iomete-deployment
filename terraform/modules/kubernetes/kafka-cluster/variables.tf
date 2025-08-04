variable "namespace" {
  description = "Kubernetes namespace to deploy Kafka cluster in"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kafka cluster"
  type        = string
  default     = "kafka-cluster"
}

variable "kafka_version" {
  description = "Version of Kafka to deploy"
  type        = string
  default     = "4.0.0"
}

variable "kafka_replicas" {
  description = "Number of Kafka broker replicas"
  type        = number
  default     = 1
}

variable "zookeeper_replicas" {
  description = "Number of Zookeeper replicas"
  type        = number
  default     = 1
}

variable "kafka_storage_size" {
  description = "Storage size for each Kafka broker"
  type        = string
  default     = "10Gi"
}

variable "zookeeper_storage_size" {
  description = "Storage size for each Zookeeper instance"
  type        = string
  default     = "5Gi"
}

variable "delete_claim_on_destroy" {
  description = "Whether to delete PVCs when the cluster is destroyed"
  type        = bool
  default     = true
}

variable "kafka_memory_request" {
  description = "Memory request for Kafka brokers"
  type        = string
  default     = "1Gi"
}

variable "kafka_cpu_request" {
  description = "CPU request for Kafka brokers"
  type        = string
  default     = "500m"
}

variable "kafka_memory_limit" {
  description = "Memory limit for Kafka brokers"
  type        = string
  default     = "2Gi"
}

variable "kafka_cpu_limit" {
  description = "CPU limit for Kafka brokers"
  type        = string
  default     = "1000m"
}

variable "zookeeper_memory_request" {
  description = "Memory request for Zookeeper"
  type        = string
  default     = "512Mi"
}

variable "zookeeper_cpu_request" {
  description = "CPU request for Zookeeper"
  type        = string
  default     = "250m"
}

variable "zookeeper_memory_limit" {
  description = "Memory limit for Zookeeper"
  type        = string
  default     = "1Gi"
}

variable "zookeeper_cpu_limit" {
  description = "CPU limit for Zookeeper"
  type        = string
  default     = "500m"
}

variable "create_test_topic" {
  description = "Whether to create a test topic"
  type        = bool
  default     = true
}

variable "operator_dependency" {
  description = "Dependency to ensure operator is deployed first"
  type        = any
  default     = null
}