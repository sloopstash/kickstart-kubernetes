variable "env" {
  type = string
  description = "CRM Environment."
}
variable "stg_vpc_cidr_blk" {
  type = string
  description = "STG VPC CIDR Block."
}
variable "stg_ec2_key_pair" {
  type = string
  description = "STG EC2 Key Pair."
}
variable "vpc_sn_conf" {
  type = map
  default = {
    "k8s_sn_1" = { "az" = "us-west-2a", "cidr" = "10.2.11.0/24" }
    "k8s_sn_2" = { "az" = "us-west-2b", "cidr" = "10.2.12.0/24" }
  }
}
variable "ec2_ami_conf" {
  type = map
  default = {
    "k8s" = { "id" = "ami-0a36eb8fadc976275" }
  }
}
