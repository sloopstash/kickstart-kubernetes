provider "aws" {
  region = "us-west-2"
  shared_credentials_file = "~/.aws/credentials"
  profile = "tuto"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iam_ec2_rl" {
  depends_on = [aws_s3_bucket.s3_osw_chef_bkt]
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
  inline_policy {
    name = "s3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid = "001"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          join(":::",[
            "arn:aws:s3",
            "${aws_s3_bucket.s3_osw_chef_bkt.id}/*"
          ])
        ]
      }]
    })
  }
  path = "/"
  tags = {
    Name = "iam-ec2-rl"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_iam_instance_profile" "iam_ec2_rl_inst_pf" {
  depends_on = [aws_iam_role.iam_ec2_rl]
  role = aws_iam_role.iam_ec2_rl.name
  path = "/"
  tags = {
    Name = "iam-ec2-rl-inst-pf"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_vpc" "vpc_net" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  instance_tenancy = "default"
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
  instance_id = aws_instance.ec2_nat_sr_1.id
}
resource "aws_subnet" "vpc_kubernetes_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = {
    Name = "vpc-kubernetes-sn-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_kubernetes_sn_1_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_kubernetes_sn_1,
    aws_route_table.vpc_pvt_rtt
  ]
  subnet_id = aws_subnet.vpc_kubernetes_sn_1.id
  route_table_id = aws_route_table.vpc_pvt_rtt.id
}
resource "aws_subnet" "vpc_kubernetes_sn_2" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${data.aws_region.current.name}b"
  tags = {
    Name = "vpc-kubernetes-sn-2"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_route_table_association" "vpc_kubernetes_sn_2_rtt_ass" {
  depends_on = [
    aws_subnet.vpc_kubernetes_sn_2,
    aws_route_table.vpc_pvt_rtt
  ]
  subnet_id = aws_subnet.vpc_kubernetes_sn_2.id
  route_table_id = aws_route_table.vpc_pvt_rtt.id
}
resource "aws_subnet" "vpc_nat_sn_1" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${data.aws_region.current.name}c"
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
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "${data.aws_region.current.name}d"
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
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "${data.aws_region.current.name}a"
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
  vpc_id = aws_vpc.vpc_net.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "${data.aws_region.current.name}b"
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
resource "aws_security_group" "vpc_kubernetes_sg" {
  depends_on = [
    aws_vpc.vpc_net,
    aws_security_group.vpc_loadbalancer_sg,
    aws_security_group.vpc_nat_sg
  ]
  vpc_id = aws_vpc.vpc_net.id
  name = "vpc-kubernetes-sg"
  ingress {
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    security_groups = [aws_security_group.vpc_loadbalancer_sg.id]
  }
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_groups = [aws_security_group.vpc_nat_sg.id]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-kubernetes-sg"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_security_group" "vpc_nat_sg" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  name = "vpc-nat-sg"
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
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vpc-nat-sg"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_security_group" "vpc_loadbalancer_sg" {
  depends_on = [aws_vpc.vpc_net]
  vpc_id = aws_vpc.vpc_net.id
  name = "vpc-loadbalancer-sg"
  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [aws_vpc.vpc_net.cidr_block]
  }
  tags = {
    Name = "vpc-loadbalancer-sg"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_s3_bucket" "s3_osw_chef_bkt" {
  bucket = "${var.aws_s3_bucket_prefix}-${var.env}-s3-osw-chef-bkt"
  acl = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET","HEAD"]
    allowed_headers = ["*"]
    expose_headers = []
    max_age_seconds = 86400
  }
  tags = {
    Name = "s3-osw-chef-bkt"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_s3_bucket_public_access_block" "s3_osw_chef_bkt_pub_acs_blk" {
  depends_on = [aws_s3_bucket.s3_osw_chef_bkt]
  bucket = aws_s3_bucket.s3_osw_chef_bkt.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true 
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
  availability_zone = "${data.aws_region.current.name}d"
  tenancy = "default"
  ebs_optimized = false
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "t3a.nano"
  key_name = aws_key_pair.ec2_key_pair.id
  vpc_security_group_ids = [aws_security_group.vpc_nat_sg.id]
  subnet_id = aws_subnet.vpc_nat_sn_2.id
  associate_public_ip_address = true
  source_dest_check = false
  iam_instance_profile = aws_iam_instance_profile.iam_ec2_rl_inst_pf.id
  credit_specification {
    cpu_credits = "standard"
  }
  tags = {
    Name = "ec2-nat-sr-1"
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_opsworks_stack" "osw_kubernetes_stk" {
  depends_on = [
    aws_iam_instance_profile.iam_ec2_rl_inst_pf,
    aws_vpc.vpc_net,
    aws_subnet.vpc_kubernetes_sn_2,
    aws_s3_bucket.s3_osw_chef_bkt
  ]
  name = "osw-kubernetes-stk"
  region = data.aws_region.current.name
  default_availability_zone = "${data.aws_region.current.name}b"
  color = "rgb(186, 65, 50)"
  service_role_arn = join(":",[
    "arn:aws:iam:",
    data.aws_caller_identity.current.account_id,
    "role/aws-opsworks-service-role"
  ])
  default_instance_profile_arn = aws_iam_instance_profile.iam_ec2_rl_inst_pf.arn
  vpc_id = aws_vpc.vpc_net.id
  default_subnet_id = aws_subnet.vpc_kubernetes_sn_2.id
  use_opsworks_security_groups = false
  default_os = "Custom"
  default_root_device_type = "ebs"
  hostname_theme = "Layer_Dependent"
  default_ssh_key_name = "ec2-key-pair"
  agent_version = "LATEST"
  configuration_manager_name = "Chef"
  configuration_manager_version = "12"
  use_custom_cookbooks = true
  custom_cookbooks_source {
    type = "s3"
    url = join("/",[
      "https://s3.amazonaws.com",
      aws_s3_bucket.s3_osw_chef_bkt.id,
      "cookbooks.tar.gz"
    ])
  }
  custom_json = jsonencode({
    system = {
      user = "ec2-user"
      group = "ec2-user"
    }
    kubernetes = {
      environment = var.env
      component = "kubernetes"
    }
  })
  manage_berkshelf = false
  tags = {
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
resource "aws_opsworks_custom_layer" "osw_kubernetes_1_lr" {
  depends_on = [
    aws_security_group.vpc_kubernetes_sg,
    aws_opsworks_stack.osw_kubernetes_stk
  ]
  name = "osw-kubernetes-1-lr"
  short_name = "osw-kubernetes-1-lr"
  stack_id = aws_opsworks_stack.osw_kubernetes_stk.id
  custom_security_group_ids = [aws_security_group.vpc_kubernetes_sg.id]
  custom_json = jsonencode({
    kubernetes = {
      cluster = 1
      token = null
      token_hash = null
      master = {
        ip_address = null
      }
    }
  })
  custom_setup_recipes = ["system::setup","docker::setup","kubernetes::setup"]
  custom_configure_recipes = []
  custom_deploy_recipes = []
  custom_undeploy_recipes = []
  custom_shutdown_recipes = ["kubernetes::stop","docker::stop","system::stop"]
  ebs_volume {
    mount_point = "/mnt/kubernetes"
    raid_level = "None"
    number_of_disks = 1
    size = 5
    type = "gp2"
    encrypted = true
  }
  auto_assign_elastic_ips = false
  auto_assign_public_ips = false
  auto_healing = false
  install_updates_on_boot = false
  instance_shutdown_timeout = 120
  drain_elb_on_shutdown = false
  use_ebs_optimized_instances = false
  tags = {
    Environment = var.env
    Region = data.aws_region.current.name
  }
}
