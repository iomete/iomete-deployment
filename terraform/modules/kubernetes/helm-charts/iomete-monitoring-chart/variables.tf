variable "iomete_monitoring_chart_version" {
  default = "The version of the monitoring Helm chart to use"
  type = string
}

variable "monitoring_namespace" {
  default = "The namespace where to install the monitoring chart"
  type = string
}

variable "control_plane_namespace" {
  default = "The namespace where the IOMETE control plane runs"
  type = string
}

variable "iomete_chart_museum_url" {
  description = "(Optional) URL for the IOMETE Chart Museum (Helm)"
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

variable "postgresql_user" {
  description = "The username for the postgresql user to monitor postgresql"
  type = string
}

variable "postgresql_password" {
  description = "The password for the postgresql user to monitor postgresql"
  type = string
}
