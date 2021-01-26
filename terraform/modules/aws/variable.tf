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
    "master_sn_1" = { "az" = "us-west-2a", "cidr" = "10.2.1.0/24" }
    "master_sn_2" = { "az" = "us-west-2b", "cidr" = "10.2.2.0/24" }
    "worker_sn_1" = { "az" = "us-west-2a", "cidr" = "10.2.3.0/24" }
    "worker_sn_2" = { "az" = "us-west-2b", "cidr" = "10.2.4.0/24" }
    "nat_sn_1" = { "az" = "us-west-2a", "cidr" = "10.2.5.0/24" }
    "nat_sn_2" = { "az" = "us-west-2b", "cidr" = "10.2.6.0/24" }
    "lb_sn_1" = { "az" = "us-west-2a", "cidr" = "10.2.7.0/24" }
    "lb_sn_2" = { "az" = "us-west-2b", "cidr" = "10.2.8.0/24" }
  }
}
variable "ec2_ami_conf" {
  type = map
  default = {
    "master" = { "id" = "ami-0a36eb8fadc976275" }
    "worker" = { "id" = "ami-0a36eb8fadc976275" }
    "nat" = { "id" = "ami-009816cdbb1e74ceb" }
  }
}
