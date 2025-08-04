variable "namespace" {
  description = "Kubernetes namespace to deploy Strimzi operator in"
  type        = string
}

variable "strimzi_operator_version" {
  description = "Version of the Strimzi operator Helm chart to install"
  type        = string
  default     = "0.47.0"
}

variable "watch_any_namespace" {
  description = "Whether the operator should watch for Kafka resources in all namespaces"
  type        = bool
  default     = true
}

variable "operator_replicas" {
  description = "Number of replicas for the Strimzi operator"
  type        = number
  default     = 1
}

variable "operator_memory_limit" {
  description = "Memory limit for the Strimzi operator"
  type        = string
  default     = "512Mi"
}

variable "operator_cpu_limit" {
  description = "CPU limit for the Strimzi operator"
  type        = string
  default     = "1000m"
}

variable "operator_memory_request" {
  description = "Memory request for the Strimzi operator"
  type        = string
  default     = "256Mi"
}

variable "operator_cpu_request" {
  description = "CPU request for the Strimzi operator"
  type        = string
  default     = "100m"
}

variable "log_level" {
  description = "Log level for the Strimzi operator"
  type        = string
  default     = "INFO"
}