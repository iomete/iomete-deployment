variable "namespace" {
  description = "Kubernetes namespace to deploy Ozone in"
  type        = string
}

variable "kubernetes_storage_provisioner" {
  description = "Kubernetes storage provisioner for the Ozone volumes"
  type        = string
}

variable "storage_class_parameters" {
  description = "Parameters for the Ozone storage class, specific to the provisioner"
  type        = map(string)
  default     = { skuname = "StandardSSD_LRS" }
}

variable "release_name" {
  description = "Helm release name. The chart derives every Service name from it, e.g. <release_name>-s3g-rest"
  type        = string
  default     = "ozone"
}

variable "chart_repository" {
  description = "Helm repository of the Apache Ozone chart"
  type        = string
  default     = "https://apache.github.io/ozone-helm-charts/"
}

variable "chart_version" {
  description = "Version of the Apache Ozone chart"
  type        = string
  default     = "0.3.0"
}

variable "image_repository" {
  description = "Ozone image repository"
  type        = string
  default     = "apache/ozone"
}

variable "image_tag" {
  description = "Ozone image tag. Keep it on the appVersion of chart_version"
  type        = string
  default     = "2.1.1"
}

variable "aws_cli_image" {
  description = "AWS CLI image used by the bucket creation job"
  type        = string
  default     = "public.ecr.aws/aws-cli/aws-cli:2.37.6"
}

variable "bucket_name" {
  description = "Bucket the module creates for the lakehouse"
  type        = string
  default     = "lakehouse"
}

variable "s3_access_key" {
  description = "S3 access key IOMETE uses. Without Kerberos, Ozone accepts any key pair"
  type        = string
  default     = "iomete"
}

variable "metadata_storage_size" {
  description = "Size of the Ozone Manager and Storage Container Manager metadata volumes"
  type        = string
  default     = "10Gi"
}

variable "datanode_storage_size" {
  description = "Size of the datanode volume, which holds all object data"
  type        = string
  default     = "10Gi"
}

variable "recon_enabled" {
  description = "Install Recon, Ozone's web UI for cluster health and browsing buckets"
  type        = bool
  default     = true
}

variable "certificate_validity_hours" {
  description = "How long the self-signed CA and server certificate stay valid. An apply after they expire creates new ones"
  type        = number
  default     = 8760 # 1 year
}
