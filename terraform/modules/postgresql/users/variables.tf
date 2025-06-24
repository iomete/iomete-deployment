variable "host" {
  description = "The Postgresql host name"
  type = string
}

variable "port" {
  description = "The Postgresql server port"
  type = number
  default = 5432
}

variable "database_name" {
  description = "The name of the Postgresql database"
  type = string
  default = null # provider defaults to postgres
}

variable "admin_username" {
  description = "The admin username for the Postgresql database"
  type = string
}

variable "admin_password" {
  description = "The admin password for the Postgresql database"
  type = string
}

variable "username" {
  description = "The name of the user to create"
  type = string
}

variable "user_creation_depends_on" {
  description = "Array of dependents user creation should wait for"
  type    = any
  default = []
}
