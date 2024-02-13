# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.0.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "marathon" {
  name     = "Marathon1"
  location = "East US"
}

resource "azurerm_service_plan" "marathon_service_plan" {
  name                = "marathon_service_plan"
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_resource_group.marathon.location
  sku_name            = "F1"
  os_type             = "Windows"

}
resource "azurerm_windows_web_app" "marathon_api" {
  name                = "marathon-api"
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    always_on = false
    application_stack {

      current_stack  = "dotnet"
      dotnet_version = "v7.0"

    }

  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_mssql_server.mssql_server.name},1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True"
  }

  connection_string {
    name  = "Redis"
    type  = "RedisCache"
    value = azurerm_redis_cache.redis.primary_connection_string
  }

}

resource "azurerm_windows_web_app" "marathon_client" {
  name                = "marathon-client"
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    always_on = false
    application_stack {
      current_stack = "node"
      node_version  = "~18"
    }
  }

  app_settings = {
    "DATABASE_CONNECTION_STRING" = "Server=tcp:${azurerm_mssql_server.mssql_server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True",
    "REDIS_CONNECTION_STRING"    = "redis://${azurerm_redis_cache.redis.hostname}.redis.cache.windows.net:${azurerm_redis_cache.redis.ssl_port}?ssl=true&sslverify=false"

  }


}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = "sql-server14"
  resource_group_name          = azurerm_resource_group.marathon.name
  location                     = azurerm_resource_group.marathon.location
  version                      = "12.0"
  administrator_login          = "Bojan"
  administrator_login_password = "PreteshkoePomosh1@!"

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "mssql_database" {
  name      = "mssql-db14"
  server_id = azurerm_mssql_server.mssql_server.id
  sku_name  = "Basic"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }

}

resource "azurerm_redis_cache" "redis" {
  name                = "redis-cache12"
  location            = azurerm_resource_group.marathon.location
  resource_group_name = azurerm_resource_group.marathon.name
  capacity            = 2
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

# output "sql_connection_string" {
#   value     = "Server=tcp:${azurerm_mssql_server.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True"
#   sensitive = true
# }

# output "redis_connection_string" {
#   value     = azurerm_redis_cache.redis.primary_connection_string
#   sensitive = true
# }

resource "azurerm_redis_firewall_rule" "redis_firewall" {
  name                = "redisFirewall12"
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = azurerm_resource_group.marathon.name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}


