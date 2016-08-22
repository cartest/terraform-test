provider "aws" {
  region = "eu-west-1"
}

# 1st STEP ################################################################################################################

module "vpc_test-1" {
  source               = "../terraform-bootstrap"
  environment          = "env1"
  project              = "project"
  vpc_cidr             = "10.2.0.0/16"
  ha-nat_subnets_cidrs = ["10.2.1.0/24","10.2.2.0/24","10.2.3.0/24"]
  private_dns_domain   = "env1.project.aws.seb"
}

# Plan: 33 to add, 0 to change, 0 to destroy.
# Apply complete! Resources: 33 added, 0 changed, 0 destroyed.

# 2nd STEP ################################################################################################################

module "vpc_test-2" {
  source               = "../terraform-bootstrap"
  environment          = "env2"
  project              = "project"
  vpc_cidr             = "172.16.0.0/16"
  ha-nat_subnets_cidrs = ["172.16.100.0/24","172.16.101.0/24","172.16.102.0/24"]
  private_dns_domain   = "env2.project.aws.seb"
  peer_matrix          = ["012345678901,vpc-abcd1234,10.2.0.0/16"]  # would like to have vars here, concat/join doesn't work
  peering_connections  = "${module.vpc_test-2.vpc_peering_ids}"     # still problem with routes 
}

# Plan: 39 to add, 0 to change, 0 to destroy.
# Apply:
# Crash with 3 errors:
# * node doesn't support evaluation: *ast.Arithmetic{Op:4, Exprs:[]ast.Node{*ast.VariableAccess{Name:"count.index", Posx:ast.Pos{Column:27, Line:1}}, *ast.VariableAccess{Name:"var.region_az_count", Posx:ast.Pos{Column:40, Line:1}}}, Posx:ast.Pos{Column:27, Line:1}} in: ${var.peering_connections[count.index / var.region_az_count]}
# Comment out: resource "aws_route" "private_nats_vpc_peers" => Plan: 36 to add, 0 to change, 0 to destroy.
# Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

# 3rd STEP ################################################################################################################

module "env_test-1" {
  source                          = "../terraform-environment"
  environment                     = "${module.vpc_test-1.environment}"
  project                         = "${module.vpc_test-1.project}"
  aws_region                      = "${module.vpc_test-1.aws_region}"
  vpc_id                          = "${module.vpc_test-1.vpc_id}"
  #bucket_name                     = "env_test-1"                       # optional  
}

module "env_test-2" {
  source                          = "../terraform-environment"
  environment                     = "${module.vpc_test-2.environment}"
  project                         = "${module.vpc_test-2.project}"
  aws_region                      = "${module.vpc_test-2.aws_region}"
  vpc_id                          = "${module.vpc_test-2.vpc_id}"
  #bucket_name                     = "env_test-2"                       # optional 
}

# Plan: 2 to add, 0 to change, 0 to destroy.
# Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

# 4th STEP ################################################################################################################

module "mservice_test-1" {
  source                          = "../terraform-microservice"
  name                            = "test-1"
  vpc_id                          = "${module.vpc_test-1.vpc_id}"                         # should be passed from env
  asg_size_min                    = "1"
  asg_size_max                    = "2"
  availability_zones              = "${module.env_test-1.azs_available_names}"
  aws_region                      = "${module.env_test-1.aws_region}"
  lc_ami_id                       = "ami-edb9069e"
  lc_instance_type                = "t2.micro"
  lc_key_name                     = "thekey"
  subnets_cidr                    = ["10.2.10.0/24", "10.2.20.0/24", "10.2.30.0/24"]
  subnets_map_public_ip_on_launch = false
  additional_security_group_ids   = ["${module.env_test-1.core_sg_id}"]
  subnets_route_tables            = ["${module.vpc_test-1.private_nat_route_table_ids}"]  # should be passed from env
  sg_cb_ingress_rule {
    cidr_blocks = "172.16.100.0/24,172.16.101.0/24"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }
  sg_cb_ingress_rule {
    cidr_blocks = "172.16.100.0/24,172.16.101.0/24"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }
  sg_ssg_ingress_rule {
    source_sg_id = "sg-b0e0d4d7"
    protocol     = "tcp"
    from_port    = 987
    to_port      = 987
  }
  sg_pl_cb_egress_rule {
    cidr_blocks     = "172.16.100.0/24,172.16.101.0/24"
    prefix_list_ids = "pl-6da54004"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
  }
  sg_pl_cb_egress_rule {
    cidr_blocks     = ""
    prefix_list_ids = "pl-6da54004"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
  }
  sg_pl_ssg_egress_rule {
    source_sg_id    = "sg-b0e0d4d7"
    prefix_list_ids = "pl-6da54004"
    protocol        = "tcp"
    from_port       = 123
    to_port         = 123
  }
  sg_pl_ssg_egress_rule {
    source_sg_id    = ""
    prefix_list_ids = "pl-6da54004"
    protocol        = "tcp"
    from_port       = 456
    to_port         = 456
  }
  tags {
    Environment = "${module.vpc_test-1.environment}"                                      # should be passed from env
    Application = "${module.vpc_test-1.project}"                                          # should be passed from env
    Tier        = "PRI"
  }
}

resource "aws_route_table_association" "test-1_private-nat" {
  count          = "3"
  subnet_id      = "${module.mservice_test-1.subnet_ids[count.index]}"
  route_table_id = "${element(module.vpc_test-1.private_nat_route_table_ids, count.index)}" # should be passed from env
}

# Plan: 23 to add, 0 to change, 0 to destroy.
# Apply:
# Crash with 1 error:
# aws_launch_configuration.launch_configuration: diffs didn't match during apply. This is a bug with Terraform and should be reported as a GitHub Issue.
# Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

# DESTROY #################################################################################################################

# Plan: 0 to add, 0 to change, 94 to destroy.
# Apply complete! Resources: 0 added, 0 changed, 82 destroyed.
