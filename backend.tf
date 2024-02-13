terraform {
  backend "azurerm" {
    storage_account_name = "storagebackend12"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
