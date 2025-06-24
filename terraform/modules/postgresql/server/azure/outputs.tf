output "host" {
  description = "The FQDN of the PostgreSQL Flexible Server"
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "port" {
  description = "The port on which to connect to the PostgreSQL Server"
  value = local.port
}

output "administrator_username" {
  description = "The username for the PostgreSQL administrator account"
  value = azurerm_postgresql_flexible_server.postgres.administrator_login
}

output "administrator_password" {
  description = "The password for the PostgreSQL administrator account"
  value = azurerm_postgresql_flexible_server.postgres.administrator_password
  sensitive = true
}

output "firewall_ip_range" {
  description = "The ip range able to access the PostgreSQL Server"
  value = {
    ip_range_start = azurerm_postgresql_flexible_server_firewall_rule.allow_azure_services.start_ip_address,
    ip_range_end   = azurerm_postgresql_flexible_server_firewall_rule.allow_azure_services.end_ip_address,
  }
}