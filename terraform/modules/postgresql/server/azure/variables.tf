variable "resource_group_name" {
  description = "Name of the resource group for the PostgreSQL server"
  type        = string
}

variable "location" {
  description = "Azure region for the PostgreSQL server"
  type        = string
}

variable "server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
}

variable "sku_name" {
  description = "(Optional) Name of the PostgreSQL SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "zone" {
  description = "(Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string
  default     = "1"
}

variable "storage_mb" {
  description = "(Optional) The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 and 33553408"
  type        = number
  default     = 32768
}

variable "postgresql_version" {
  description = "(Optional) The version of PostgreSQL Flexible Server to use"
  type        = string
  default     = "16"
}

variable "max_connections" {
  description = "(Optional) The maximum number of connections the server will allow"
  type        = number
  default     = 500
}

variable "admin_username" {
  description = "(Optional) PostgreSQL admin username"
  type        = string
  default     = "admin"
}

variable "tags" {
  description = "(Optional) Tags to apply to all resources"
  type = map(string)
  default = {}
}

variable "enable_public_access" {
  description = "(Optional) If this Postgresql instance should be publicly accessible"
  type = bool
  default = true
}

variable "ip_range_access" {
  description = "(Optional) The start and end range of the ip-addresses that can access this PostgreSQL server"
  type = object({
    begin = string
    end   = string
  })
  default = {
    begin = "0.0.0.0"
    end   = "255.255.255.255"
  }
}
