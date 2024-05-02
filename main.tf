terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "prefix" {
  description = "name of resource group"
  type = map(string)
  default = {
    "dev" = "tejadevsg"
    "stage" = "tejastagesg"
    "prod" = "tejaprodsg"
  }
}

module "resourcegreouptest" {
  source = "./modules/vm"
  prefix = lookup(var.prefix, terraform.workspace, "tejadefaultsg")
}









example for vault code

provider "aws" {
    region = "us-east-1"
}

provider "vault" {
    address = "10.2.3.4:4056"
    skip_child_token = true
    auth_login {
        path = "auth/approle/login"
        parameters = {
          role_id = "fsdf"
          secret_id = "dfgdfhg"
        }
    }
}

data "vault_kv_secret_v2" "example" {
    mount = "kv"
    name = "test-secret"
}

resource "aws_instance" "new" {
    ami = "ami-34346456456"
    tags = {
      secret = data.vault_kv_secret_v2.example.data["username"]
      name = "sampleec2instance"
      environment = "production"
    }
}


