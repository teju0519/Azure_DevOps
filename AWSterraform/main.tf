terraform {
  backend "s3" {
    bucket = "tejas3"
    key = "/var/lib/terraform.tfstate"
    encrypt = true
    dynamodb_table = "terraform-lock-state"
  }
}

provider "aws" {
  region = "us-east-1"
}

