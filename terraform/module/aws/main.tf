provider "aws" {
  region = "us-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "tuto"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iam_ec2_rl" {
  name = "iam-ec2-rl"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
  max_session_duration = 3600
  path = "/"
  tags = {
    Name = "iam-ec2-rl"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_iam_instance_profile" "iam_ec2_rl_inst_pf" {
  depends_on = [aws_iam_role.iam_ec2_rl]
  name = "iam-ec2-rl-inst-pf"
  path = "/"
  role = aws_iam_role.iam_ec2_rl.name
  tags = {
    Name = "iam-ec2-rl-inst-pf"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_iam_role" "iam_eks_rl" {
  name = "iam-eks-rl"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
  max_session_duration = 3600
  path = "/"
  tags = {
    Name = "iam-eks-rl"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_iam_instance_profile" "iam_eks_rl_inst_pf" {
  depends_on = [aws_iam_role.iam_eks_rl]
  name = "iam-eks-rl-inst-pf"
  path = "/"
  role = aws_iam_role.iam_eks_rl.name
  tags = {
    Name = "iam-eks-rl-inst-pf"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_vpc" "vpc_net" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_network_address_usage_metrics = false
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "vpc-net"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_internet_gateway" "vpc_ig" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-ig"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table" "vpc_pub_rtt" {
  depends_on = [
    aws_vpc.vpc_net,
    aws_internet_gateway.vpc_ig
  ]
  vpc_id = aws_vpc.vpc_net.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_ig.id
  }
  tags = {
    Name = "vpc-pub-rtt"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table" "vpc_pvt_rtt" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-pvt-rtt"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route" "vpc_pvt_rtt_rt_1" {
  depends_on = [
    aws_route_table.vpc_pvt_rtt,
    aws_instance.ec2_nat_sr_1
  ]
  route_table_id = aws_route_table.vpc_pvt_rtt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.ec2_nat_sr_1.primary_network_interface_id
}
resource "aws_subnet" "vpc_eks_cp_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block = "10.0.1.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-eks-cp-sn-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_eks_cp_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_eks_cp_sn_1,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_eks_cp_sn_1.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_subnet" "vpc_eks_cp_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}b"
  cidr_block = "10.0.2.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-eks-cp-sn-2"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_eks_cp_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_eks_cp_sn_2,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_eks_cp_sn_2.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_subnet" "vpc_eks_nd_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block = "10.0.3.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-eks-nd-sn-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_eks_nd_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_eks_nd_sn_1,
    aws_route_table.vpc_pvt_rtt
  ]
  subnet_id = aws_subnet.vpc_eks_nd_sn_1.id
  route_table_id = aws_route_table.vpc_pvt_rtt.id
}
resource "aws_subnet" "vpc_eks_nd_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}d"
  cidr_block = "10.0.4.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-eks-nd-sn-2"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_eks_nd_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_eks_nd_sn_2,
    aws_route_table.vpc_pvt_rtt
  ]
  subnet_id = aws_subnet.vpc_eks_nd_sn_2.id
  route_table_id = aws_route_table.vpc_pvt_rtt.id
}
resource "aws_subnet" "vpc_nat_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}a"
  cidr_block = "10.0.5.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-nat-sn-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_nat_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_nat_sn_1,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_nat_sn_1.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_subnet" "vpc_nat_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}b"
  cidr_block = "10.0.6.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-nat-sn-2"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_nat_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_nat_sn_2,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_nat_sn_2.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_subnet" "vpc_loadbalancer_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}c"
  cidr_block = "10.0.7.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-loadbalancer-sn-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_loadbalancer_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_loadbalancer_sn_1,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_loadbalancer_sn_1.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_subnet" "vpc_loadbalancer_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  assign_ipv6_address_on_creation = false
  availability_zone = "${data.aws_region.current.name}d"
  cidr_block = "10.0.8.0/24"
  enable_dns64 = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  enable_resource_name_dns_a_record_on_launch = false
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-loadbalancer-sn-2"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_loadbalancer_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_loadbalancer_sn_2,
    aws_route_table.vpc_pub_rtt
  ]
  subnet_id = aws_subnet.vpc_loadbalancer_sn_2.id
  route_table_id = aws_route_table.vpc_pub_rtt.id
}
resource "aws_security_group" "vpc_eks_sg" {
  depends_on = [aws_vpc.vpc_net]
  name = "vpc-eks-sg"
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }
  revoke_rules_on_delete = false
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-eks-sg"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_security_group" "vpc_nat_sg" {
  depends_on = [aws_vpc.vpc_net]
  name = "vpc-nat-sg"
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [aws_vpc.vpc_net.cidr_block]
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  revoke_rules_on_delete = false
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-nat-sg"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_security_group" "vpc_loadbalancer_sg" {
  depends_on = [aws_vpc.vpc_net]
  name = "vpc-loadbalancer-sg"
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [aws_vpc.vpc_net.cidr_block]
  }
  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  revoke_rules_on_delete = false
  vpc_id = aws_vpc.vpc_net.id
  tags = {
    Name = "vpc-loadbalancer-sg"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_key_pair" "ec2_key_pair" {
  key_name = "ec2-key-pair"
  public_key = var.ssh_public_key
  tags = {
    Name = "ec2-key-pair"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_instance" "ec2_nat_sr_1" {
  depends_on = [
    aws_iam_instance_profile.iam_ec2_rl_inst_pf,
    aws_vpc.vpc_net,
    aws_subnet.vpc_nat_sn_2,
    aws_security_group.vpc_nat_sg
  ]
  ami = "ami-0a4bc8a5c1ed3b5a3"
  associate_public_ip_address = true
  cpu_options {
    core_count = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "standard"
  }
  disable_api_stop = false
  disable_api_termination = false
  ebs_optimized = false
  hibernation = false
  iam_instance_profile = aws_iam_instance_profile.iam_ec2_rl_inst_pf.id
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "t3a.micro"
  key_name = aws_key_pair.ec2_key_pair.id
  monitoring = false
  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = true
    enable_resource_name_dns_a_record = true
    hostname_type = "ip-name"
  }
  vpc_security_group_ids = [aws_security_group.vpc_nat_sg.id]
  source_dest_check = false
  subnet_id = aws_subnet.vpc_nat_sn_2.id
  tenancy = "default"
  tags = {
    Name = "ec2-nat-sr-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_eks_cluster" "eks_ct" {
  depends_on = [
    aws_iam_role.iam_eks_rl,
    aws_vpc.vpc_net,
    aws_subnet.vpc_eks_cp_sn_1,
    aws_subnet.vpc_eks_cp_sn_2,
    aws_subnet.vpc_eks_nd_sn_1,
    aws_subnet.vpc_eks_nd_sn_2,
    aws_security_group.vpc_eks_sg
  ]
  name = "eks-ct"
  role_arn = aws_iam_role.iam_eks_rl.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    security_group_ids = [aws_security_group.vpc_eks_sg.id]
    subnet_ids = [
      aws_subnet.vpc_eks_cp_sn_1.id,
      aws_subnet.vpc_eks_cp_sn_2.id,
      aws_subnet.vpc_eks_nd_sn_1.id,
      aws_subnet.vpc_eks_nd_sn_2.id
    ]
  }
  version = 1.24
  tags = {
    Name = "eks-ct"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_eks_node_group" "eks_gnr_ng" {
  depends_on = [
    aws_iam_role.iam_ec2_rl,
    aws_vpc.vpc_net,
    aws_subnet.vpc_eks_nd_sn_1,
    aws_subnet.vpc_eks_nd_sn_2,
    aws_security_group.vpc_nat_sg,
    aws_key_pair.ec2_key_pair,
    aws_eks_cluster.eks_ct
  ]
  node_group_name = "eks-gnr-ng"
  cluster_name = aws_eks_cluster.eks_ct.name
  node_role_arn = aws_iam_role.iam_ec2_rl.arn
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 1
  }
  subnet_ids = [
    aws_subnet.vpc_eks_nd_sn_1.id,
    aws_subnet.vpc_eks_nd_sn_2.id
  ]
  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size = 8
  force_update_version = true
  instance_types = ["t3a.small"]
  remote_access {
    ec2_ssh_key = aws_key_pair.ec2_key_pair.id
    source_security_group_ids = [aws_security_group.vpc_nat_sg.id]
  }
  update_config {
    max_unavailable_percentage = 30
  }
  version = 1.24
  tags = {
    Name = "eks-gnr-ng"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
