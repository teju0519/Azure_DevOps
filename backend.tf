terraform {
  backend "azurerm" {
    storage_account_name = "tfvmexsa"
    container_name = "content"
    key = "terraform.tfstate"
  }
}
