variable "namespace" {
  description = "Kubernetes namespace to deploy Minio in"
  type        = string
}

variable "kubernetes_storage_provisioner" {
  description = "Kubernetes storage provisioner for minio"
  type        = string
}

variable "pvc_name" {
  description = "Kubernetes pvc name for minio"
  type        = string
  default     = "minio-fs-pvc"
}

variable "name" {
  description = "Name for the Minio deployment"
  type        = string
  default     = "minio"
}

variable "minio_version" {
  description = "Minio image version/tag"
  type        = string
  default     = "latest"
}

variable "minio_root_user" {
  description = "Minio root username"
  type        = string
  default     = "minioadmin"
  sensitive   = true
}

variable "storage_size" {
  description = "Size of persistent volume for Minio data"
  type        = string
  default     = "10Gi"
}

variable "service_type" {
  description = "Kubernetes service type for Minio"
  type        = string
  default     = "ClusterIP"
}