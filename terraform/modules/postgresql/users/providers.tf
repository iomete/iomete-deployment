terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
    }
  }
}

provider "postgresql" {
  host     = var.host
  port     = var.port
  database = var.database_name
  username = var.admin_username
  password = var.admin_password
  superuser = false
  sslmode  = "require"
}
