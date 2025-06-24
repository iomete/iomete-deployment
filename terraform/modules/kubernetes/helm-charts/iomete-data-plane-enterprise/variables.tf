variable "namespace" {
  description = "Kubernetes namespace to deploy IOMETE in"
  type        = string
}

variable "iomete_dataplane_enterprise_chart_version" {
  description = "Version of the IOMETE dataplane enterprise Helm chart to install"
  type        = string
}

variable "iomete_dataplane_crds_chart_version" {
  description = "Version of the IOMETE dataplane crds Helm chart to install"
  type        = string
  default     = "1.0.0"
}

variable "iomete_chart_museum_url" {
  description = "URL for the IOMETE Chart Museum (Helm)"
  type        = string
  default     = "https://chartmuseum.iomete.com"
}

variable "postgresql_host" {
  description = "The postgresql hostname for IOMETE-system"
  type = string
}

variable "postgresql_port" {
  description = "The postgresql port to connect to"
  type = number
}

variable "postgresql_admin_user" {
  description = "The postgresql admin username"
  type = string
}

variable "postgresql_admin_password" {
  description = "The postgresql admin username"
  type = string
}

variable "postgresql_user" {
  description = "The username for the postgresql user iomete components will use"
  type = string
}

variable "postgresql_password" {
  description = "The password for the postgresql user iomete components will use"
  type = string
}

variable "minio_uri" {
  description = "Minio URI to connect to for the lakehouse"
  type = string
}

variable "minio_username" {
  description = "Username to use when connecting to Minio"
  type = string
}

variable "minio_secret" {
  description = "Password to use when connecting to Minio"
  type = string
}

variable "certificates" {
  description = "(Optional) list of certificates that will be placed in a truststore and used by the IOMETE services"
  type = set(string)
  default = []
}