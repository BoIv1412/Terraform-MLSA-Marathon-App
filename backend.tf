terraform {
  backend "azurerm" {
    storage_account_name = "storagebackend12"
    container_name       = "tfstate"
    key                  = "Terraform/terraform.tfstate"
    resource_group_name  = "Marathon1"
  }
}
