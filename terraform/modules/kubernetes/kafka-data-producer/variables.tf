variable "namespace" {
  description = "Kubernetes namespace to deploy Kafka producer in"
  type        = string
}

variable "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers"
  type        = string
}

variable "topic_name" {
  description = "Kafka topic to send messages to"
  type        = string
  default     = "events"
}

variable "data_type" {
  description = "Type of data to generate (e-commerce, iot, clickstream)"
  type        = string
  default     = "e-commerce"
}

variable "message_interval_seconds" {
  description = "Interval between messages in seconds"
  type        = number
  default     = 5
}