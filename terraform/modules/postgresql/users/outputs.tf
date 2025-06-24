output "username" {
  description = "The login for the created user"
  value = postgresql_role.user.name
}

output "password" {
  description = "The password for the created user"
  value = postgresql_role.user.password
  sensitive = true
}