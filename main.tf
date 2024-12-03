terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations {
    enabled = false
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "marathon" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "marathon_service_plan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_resource_group.marathon.location
  sku_name            = "F1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "marathon_api" {
  name                = var.app_name_api
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    always_on = false
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v7.0"
    }
    cors {
      allowed_origins     = ["https://marathon-client.azurewebsites.net"]
      support_credentials = true
    }
  }
}

resource "azurerm_windows_web_app" "marathon_client" {
  name                = var.app_name_client
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    always_on = false
    application_stack {
      current_stack = "node"
      node_version  = "~18"
    }
    cors {
      allowed_origins     = ["https://marathon-api.azurewebsites.net"]
      support_credentials = true
    }
  }
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.marathon.name
  location                     = azurerm_resource_group.marathon.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "mssql_database" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.mssql_server.id
  sku_name  = "Basic"
}

resource "azurerm_redis_cache" "redis" {
  name                = var.redis_cache_name
  location            = azurerm_resource_group.marathon.location
  resource_group_name = azurerm_resource_group.marathon.name
  capacity            = 2
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"

  redis_configuration {}
}

resource "azurerm_redis_firewall_rule" "redis_firewall" {
  name                = "redis_firewall_rule"
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = azurerm_resource_group.marathon.name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}

resource "azurerm_mssql_firewall_rule" "dbfirewall" {
  name             = "db_firewall_rule"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_key_vault" "key_vault" {
  name                     = var.key_vault_name
  location                 = azurerm_resource_group.marathon.location
  resource_group_name      = azurerm_resource_group.marathon.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false
  sku_name                 = "standard"
}

resource "azurerm_key_vault_access_policy" "bojan_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.user_object_id

  key_permissions = ["Get"]
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

resource "azurerm_key_vault_secret" "key_vault_secret1" {
  name         = var.key_vault_secret_connection_string_name
  value        = "Server=tcp:${azurerm_mssql_server.mssql_server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};User ID=${var.sql_admin_user};Password=${var.sql_admin_password};Encrypt=True;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.key_vault.id
}
