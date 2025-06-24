locals {
  port = 5432 # Default postgresql port set by Azure
}

resource "random_password" "postgresql_admin_password" {
  length  = 12
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name   = var.sku_name
  version    = var.postgresql_version
  storage_mb = var.storage_mb

  administrator_login    = var.admin_username
  administrator_password = random_password.postgresql_admin_password.result
  zone                   = var.zone

  public_network_access_enabled = var.enable_public_access

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  name      = "max_connections"
  value     = var.max_connections
  server_id = azurerm_postgresql_flexible_server.postgres.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = var.ip_range_access.begin
  end_ip_address   = var.ip_range_access.end
}
