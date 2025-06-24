resource "random_password" "postgresql_user_password" {
  length  = 12
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "postgresql_role" "user" {
  depends_on = [var.user_creation_depends_on]

  name     = var.username
  login    = true
  password = random_password.postgresql_user_password.result

  superuser       = false
  create_database = false
  create_role     = false
  skip_drop_role  = true
}