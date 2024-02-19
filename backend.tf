terraform {
  backend "azurerm" {
    storage_account_name = "backendstorage14"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "backendT"
  }
}
