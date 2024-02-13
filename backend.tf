terraform {
  backend "azurerm" {
    storage_account_name = "storagebackend12"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "marathon"
  }
}
