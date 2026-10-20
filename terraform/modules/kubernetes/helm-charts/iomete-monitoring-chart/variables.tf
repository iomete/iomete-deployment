variable "iomete_monitoring_chart_version" {
  description = "The version of the monitoring Helm chart to use"
  type        = string
}

variable "monitoring_namespace" {
  description = "The namespace where to install the monitoring chart"
  type        = string
}

variable "control_plane_namespace" {
  description = "The namespace where the IOMETE control plane runs"
  type        = string
}

variable "iomete_chart_museum_url" {
  description = "(Optional) URL for the IOMETE Chart Museum (Helm)"
  type        = string
  default     = "https://chartmuseum.iomete.com"
}

variable "postgresql_host" {
  description = "The PostgreSQL hostname to monitor"
  type        = string
}

variable "postgresql_port" {
  description = "The PostgreSQL port to connect to"
  type        = number
}

variable "postgresql_user" {
  description = "The PostgreSQL user to monitor PostgreSQL with"
  type        = string
}

variable "postgresql_password" {
  description = "The password of the PostgreSQL user to monitor PostgreSQL with"
  type        = string
  sensitive   = true
}
