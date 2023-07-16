terraform {
  required_version = "v1.0.1"
  required_providers {
    aws = "5.8.0"
  }
  backend "local" {
    path = "main.tfstate"
  }
}

module "aws" {
  source = "./module/aws"
  env = var.env
  ssh_public_key = var.ssh_public_key
}
