variable "namespace" {
  description = "Kubernetes namespace to deploy IOMETE in"
  type        = string
}

variable "iomete_dataplane_enterprise_chart_version" {
  description = "Version of the IOMETE data plane enterprise Helm chart to install"
  type        = string
}

variable "iomete_chart_museum_url" {
  description = "URL for the IOMETE Chart Museum (Helm)"
  type        = string
  default     = "https://chartmuseum.iomete.com"
}

variable "admin_email" {
  description = "Email of the IOMETE console admin user"
  type        = string
}

variable "postgresql_host" {
  description = "The PostgreSQL hostname for IOMETE"
  type        = string
}

variable "postgresql_port" {
  description = "The PostgreSQL port to connect to"
  type        = number
}

variable "postgresql_admin_user" {
  description = "The PostgreSQL admin username, used to create the IOMETE databases"
  type        = string
}

variable "postgresql_admin_password" {
  description = "The PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgresql_user" {
  description = "The PostgreSQL user the IOMETE services connect as"
  type        = string
}

variable "postgresql_password" {
  description = "The password of the PostgreSQL user the IOMETE services connect as"
  type        = string
  sensitive   = true
}

variable "storage" {
  description = "The chart's storage block (type, bucketName and the backend-specific settings)"
  type        = any
}

variable "extra_values" {
  description = "(Optional) Top-level chart values merged over the ones this module sets"
  type        = any
  default     = {}
}
