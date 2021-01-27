provider "aws" {
  region = "us-west-2"
  shared_credentials_file = "~/.aws/credentials"
  profile = "tuto"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "stg_iam_ec2_rl" {
  name = "STG-IAM-EC2-RL"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  path = "/"
  tags = {
    Name = "STG-IAM-EC2-RL"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_iam_instance_profile" "stg_iam_ec2_rl_inst_pf" {
  depends_on = [aws_iam_role.stg_iam_ec2_rl]
  path = "/"
  role = aws_iam_role.stg_iam_ec2_rl.name
}
resource "aws_vpc" "stg_vpc" {
  cidr_block = var.stg_vpc_cidr_blk
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "STG-VPC"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_internet_gateway" "stg_vpc_ig" {
  depends_on = [aws_vpc.stg_vpc]
  vpc_id = aws_vpc.stg_vpc.id
  tags = {
    Name = "STG-VPC-IG"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_route_table" "stg_vpc_rtt_pub" {
  depends_on = [aws_vpc.stg_vpc, aws_internet_gateway.stg_vpc_ig]
  vpc_id = aws_vpc.stg_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stg_vpc_ig.id
  }
  tags = {
    Name = "STG-VPC-RTT-PUB"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_subnet" "stg_vpc_k8s_sn_1" {
  depends_on = [aws_vpc.stg_vpc]
  vpc_id = aws_vpc.stg_vpc.id
  cidr_block = var.vpc_sn_conf["k8s_sn_1"]["cidr"]
  availability_zone = var.vpc_sn_conf["k8s_sn_1"]["az"]
  tags = {
    Name = "STG-VPC-K8S-SN-1"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_route_table_association" "stg_vpc_k8s_sn_1_rtt_ass" {
  depends_on = [aws_vpc.stg_vpc, aws_subnet.stg_vpc_k8s_sn_1, aws_route_table.stg_vpc_rtt_pub]
  subnet_id = aws_subnet.stg_vpc_k8s_sn_1.id
  route_table_id = aws_route_table.stg_vpc_rtt_pub.id
}
resource "aws_subnet" "stg_vpc_k8s_sn_2" {
  depends_on = [aws_vpc.stg_vpc]
  vpc_id = aws_vpc.stg_vpc.id
  cidr_block = var.vpc_sn_conf["k8s_sn_2"]["cidr"]
  availability_zone = var.vpc_sn_conf["k8s_sn_2"]["az"]
  tags = {
    Name = "STG-VPC-K8S-SN-2"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_route_table_association" "stg_vpc_k8s_sn_2_rtt_ass" {
  depends_on = [aws_vpc.stg_vpc, aws_subnet.stg_vpc_k8s_sn_2, aws_route_table.stg_vpc_rtt_pub]
  subnet_id = aws_subnet.stg_vpc_k8s_sn_2.id
  route_table_id = aws_route_table.stg_vpc_rtt_pub.id
}
resource "aws_security_group" "stg_vpc_k8s_sg" {
  depends_on = [aws_vpc.stg_vpc]
  vpc_id = aws_vpc.stg_vpc.id
  name = "STG-VPC-K8S-SG"
  description = "STG VPC K8S Security Group."
  ingress {
    protocol = "tcp"
    from_port = 30080
    to_port = 30080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "STG-VPC-K8S-SG"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_instance" "stg_ec2_k8s_mtr_1" {
  depends_on = [aws_iam_instance_profile.stg_iam_ec2_rl_inst_pf, aws_vpc.stg_vpc, aws_subnet.stg_vpc_k8s_sn_1, aws_security_group.stg_vpc_k8s_sg]
  ami = var.ec2_ami_conf["k8s"]["id"]
  availability_zone = var.vpc_sn_conf["k8s_sn_1"]["az"]
  tenancy = "default"
  ebs_optimized = false
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "t3a.small"
  key_name = var.stg_ec2_key_pair
  security_groups = [aws_security_group.stg_vpc_k8s_sg.id]
  subnet_id = aws_subnet.stg_vpc_k8s_sn_1.id
  associate_public_ip_address = true
  private_ip = "10.2.11.10"
  source_dest_check = false
  iam_instance_profile = aws_iam_instance_profile.stg_iam_ec2_rl_inst_pf.id
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "STG-EC2-K8S-MTR-1"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
resource "aws_instance" "stg_ec2_k8s_wkr_1" {
  depends_on = [aws_iam_instance_profile.stg_iam_ec2_rl_inst_pf, aws_vpc.stg_vpc, aws_subnet.stg_vpc_k8s_sn_2, aws_security_group.stg_vpc_k8s_sg]
  ami = var.ec2_ami_conf["k8s"]["id"]
  availability_zone = var.vpc_sn_conf["k8s_sn_2"]["az"]
  tenancy = "default"
  ebs_optimized = false
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "t3a.small"
  key_name = var.stg_ec2_key_pair
  security_groups = [aws_security_group.stg_vpc_k8s_sg.id]
  subnet_id = aws_subnet.stg_vpc_k8s_sn_2.id
  associate_public_ip_address = true
  private_ip = "10.2.12.10"
  source_dest_check = false
  iam_instance_profile = aws_iam_instance_profile.stg_iam_ec2_rl_inst_pf.id
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "STG-EC2-K8S-WKR-1"
    Environment = "STG"
    Region = "us-west-2"
    Product = "CRM"
  }
}
