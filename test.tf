module "vpc_test-1" {
  source              = "../terraform-bootstrap"
  environment         = "env1"
  project             = "project"
  vpc_cidr            = "10.0.0.0/16"
  private_dns_domain  = "env1.project.aws.test"
}

module "vpc_test-2" {
  source              = "../terraform-bootstrap"
  environment         = "env2"
  project             = "project"
  vpc_cidr            = "172.16.0.0/16"
  private_dns_domain  = "env2.project.aws.test"
  peer_matrix         = ["012345678901,vpc-00000000,10.0.0.0/16"] # would like to have vars here
}

module "env_test-1" {
  source                          = "../terraform-environment"
  environment                     = "${module.vpc_test-1.environment}"
  project                         = "${module.vpc_test-1.project}"
  aws_region                      = "${module.vpc_test-1.aws_region}"
  vpc_id                          = "${module.vpc_test-1.vpc_id}"
  bootstrap_public_route_table_id = "rtb-00000000"  # didn't work with variable passwed from boostrap module
  internet_gateway_id             = "${module.vpc_test-1.internet_gateway_id}"
  #example_bucket_name             = "shakalaka"  # optional
}

module "env_test-2" {
  source                          = "../terraform-environment"
  environment                     = "${module.vpc_test-2.environment}"
  project                         = "${module.vpc_test-2.project}"
  aws_region                      = "${module.vpc_test-2.aws_region}"
  vpc_id                          = "${module.vpc_test-2.vpc_id}"
  bootstrap_public_route_table_id = "rtb-e50d7281"
  internet_gateway_id             = "${module.vpc_test-2.internet_gateway_id}"
  #example_bucket_name             = "shakalaka"  # optional
}

module "mservice_test-1" {
  source                          = "../terraform-microservice"
  additional_security_group_ids   = ["${module.env_test-1.core_sg_id}"]
  asg_size_max                    = "3"
  asg_size_min                    = "3"
  availability_zones              = "${module.env_test-1.azs_available_names}"
  aws_region                      = "${module.env_test-1.aws_region}"
  lc_ami_id                       = "ami-edb9069e"
  lc_instance_type                = "t2.micro"
  name                            = "test1"
  subnets_cidr                    = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  subnets_map_public_ip_on_launch = false
  subnets_route_tables            = ["${module.env_test-1.private_nats_ids}"]
  vpc_id                          = "${module.vpc_test-1.vpc_id}"
  tags {
    Environment = "${module.vpc_test-1.environment}"
    Application = "${module.vpc_test-1.project}"
    Tier        = "PRI"
  }
}

resource "aws_route_table_association" "test-1_private-nat" {
  count          = "3"
  subnet_id      = "${module.mservice_test-1.subnet_ids[count.index]}"
  route_table_id = "${element(module.env_test-1.private_nats_ids, count.index)}"
}

# module "ha-nat-1" {
#   source               = "../terraform-ha-nat"
#   availability_zones   = "${module.env_test-1.azs_available_names}"
#   aws_region           = "${module.env_test-1.aws_region}"
#   gateway_route_tables = ["${module.env_test-1.private_nats_ids}"]
#   name                 = "ha-nat"
#   subnets_cidr         = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
#   subnets_route_tables = ["rtb-d6116eb2"]
#   vpc_id               = "${module.vpc_test-1.vpc_id}"
#   tags {
#     Environment = "${module.vpc_test-1.environment}"
#     Application = "${module.vpc_test-1.project}"
#     Tier        = "PUB"
#   }
# }

# resource "aws_route_table_association" "ha-nat-1_public" {
#   count          = "3" #${module.env_test-1.region_az_count}"
#   subnet_id      = "${module.ha-nat-1.subnet_ids[count.index]}"
#   route_table_id = "${module.vpc_test-1.bootstrap_public_route_table_id}"
# }
