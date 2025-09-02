variable "namespace" {
  default = "The namespace where to install airflow"
  type = string
}

variable "chart_museum_url" {
  description = "(Optional) URL for the Airflow Chart Museum (Helm)"
  type        = string
  default     = "https://airflow.apache.org"
}

variable "chart_version" {
  description = "(Optional) The desired version of the chart to install"
  type        = string
  default     = "1.16.0"
}

variable "postgresql_host" {
  description = "The postgresql hostname for airflow"
  type = string
}

variable "postgresql_port" {
  description = "The postgresql port to connect to"
  type = number
}

variable "postgresql_username" {
  description = "The username for the postgresql user"
  type = string
}

variable "postgresql_password" {
  description = "The password for the postgresql user "
  type = string
}

variable "postgresql_database" {
  description = "The database airflow should connect to"
  type = string
}