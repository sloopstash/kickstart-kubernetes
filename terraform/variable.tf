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
