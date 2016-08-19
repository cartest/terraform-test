module "vpc_test-1" {
  source               = "../terraform-bootstrap"
  environment          = "env1"
  project              = "project"
  vpc_cidr             = "10.2.0.0/16"
  ha-nat_subnets_cidrs = ["10.2.1.0/24","10.2.2.0/24","10.2.3.0/24"]
  private_dns_domain   = "env1.project.aws.seb"
}

module "vpc_test-2" {
  source               = "../terraform-bootstrap"
  environment          = "env2"
  project              = "project"
  vpc_cidr             = "172.16.0.0/16"
  ha-nat_subnets_cidrs = ["172.16.100.0/24","172.16.101.0/24","172.16.102.0/24"]
  private_dns_domain   = "env2.project.aws.seb"
  peer_matrix          = ["096334345123,vpc-83e853e7,10.2.0.0/16"]  # would like to have vars here, concat/join doesn't work
  peering_connections  = "${module.vpc_test-2.vpc_peering_ids}"     # still problem with routing tables 
}

# 
module "env_test-1" {
  source                          = "../terraform-environment"
  environment                     = "${module.vpc_test-1.environment}"
  project                         = "${module.vpc_test-1.project}"
  aws_region                      = "${module.vpc_test-1.aws_region}"
  vpc_id                          = "${module.vpc_test-1.vpc_id}"
  #bucket_name                     = "env_test-1"  # optional  
}

module "env_test-2" {
  source                          = "../terraform-environment"
  environment                     = "${module.vpc_test-2.environment}"
  project                         = "${module.vpc_test-2.project}"
  aws_region                      = "${module.vpc_test-2.aws_region}"
  vpc_id                          = "${module.vpc_test-2.vpc_id}"
  #bucket_name                     = "env_test-2"  # optional 
}

# doesn't work yet :/
module "mservice_test-1" {
  source                          = "../terraform-microservice"
  additional_security_group_ids   = ["${module.env_test-1.core_sg_id}"]
  asg_size_min                    = "1"
  asg_size_max                    = "2"
  availability_zones              = "${module.env_test-1.azs_available_names}"
  aws_region                      = "${module.env_test-1.aws_region}"
  lc_ami_id                       = "ami-edb9069e"
  lc_instance_type                = "t2.micro"
  lc_key_name                     = "thekey"
  name                            = "test1"
  subnets_cidr                    = ["10.2.10.0/24", "10.2.20.0/24", "10.2.30.0/24"]
  subnets_map_public_ip_on_launch = false
  subnets_route_tables            = ["${module.vpc_test-1.private_nat_route_table_ids}"]  # should be passed from env
  vpc_id                          = "${module.vpc_test-1.vpc_id}"                         # should be passed from env
  tags {
    Environment = "${module.vpc_test-1.environment}"                                      # should be passed from env
    Application = "${module.vpc_test-1.project}"                                          # should be passed from env
    Tier        = "PRI"
  }
}