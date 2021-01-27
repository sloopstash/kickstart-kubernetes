terraform {
  required_version = "v0.14.4"
  required_providers {
    aws = "3.23.0"
  }
  backend "local" {
    path = "stg-tfm-base-cfg.tfstate"
  }
}

module "aws" {
  source = "./module/aws"
  env = var.env
  stg_vpc_cidr_blk = var.stg_vpc_cidr_blk
  stg_ec2_key_pair = var.stg_ec2_key_pair
}
