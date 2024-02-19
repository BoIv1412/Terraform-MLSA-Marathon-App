variable "location" {
  description = "The location where the Azure resources will be deployed."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "Marathon1"
}

variable "service_plan_name" {
  description = "The name of the Azure App Service plan."
  type        = string
  default     = "marathon_service_plan"
}

variable "app_name_api" {
  description = "The name of the Azure Web App for the API."
  type        = string
  default     = "marathon-api"
}

variable "app_name_client" {
  description = "The name of the Azure Web App for the client."
  type        = string
  default     = "marathon-client"
}

variable "sql_server_name" {
  description = "The name of the SQL Server."
  type        = string
  default     = "sql-server14"
}

variable "sql_database_name" {
  description = "The name of the SQL Database."
  type        = string
  default     = "mssql-db14"
}

variable "redis_cache_name" {
  description = "The name of the Redis Cache."
  type        = string
  default     = "redis-cache12"
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
  default     = "keyvault125347"
}

variable "key_vault_secret_connection_string_name" {
  description = "The name of the Key Vault secret for the connection string."
  type        = string
  default     = "default-connection-string"
}

variable "key_vault_secret_redis_connection_string_name" {
  description = "The name of the Key Vault secret for the Redis connection string."
  type        = string
  default     = "redis-connection-string"
}

variable "user_object_id" {
  description = "The object ID of the user to grant access to the Key Vault."
  type        = string
  default     = "b57ee40a-d60f-4fec-888e-91ba79c1f277" # You can change this default value to the actual object ID
}

variable "display_name" {
  description = "Used for the service principal"
  type        = string
  default     = "MarathonT"
}

variable "redis_name" {
  description = "Name for Redis"
  type        = string
  default     = "redisFirewall12"
}

variable "redis_firewall" {
  description = "Name for Redis Firewall"
  type        = string
  default     = "FirewallRule1"
}
