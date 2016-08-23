provider "aws" {
  region = "eu-west-1"
}

variable "private_nat_route_table_ids" {                          # just to simplify things for testing purposes
  default = ["rtb-XXXXXXXX","rtb-XXXXXXXX","rtb-XXXXXXXX"]        # manual entries
}

module "mservice_test-1" {
  source                          = "../../terraform-microservice"
  name                            = "test-1"
  vpc_id                          = "vpc-XXXXXXXX"      # manual entry
  asg_size_min                    = "1"
  asg_size_max                    = "2"
  availability_zones              = ["eu-west-1a","eu-west-1b","eu-west-1c"]
  aws_region                      = "eu-west-1"
  lc_ami_id                       = "ami-XXXXXXXX"      # manual entry
  lc_instance_type                = "t2.micro"
  lc_key_name                     = "XXXXXXXX"          # manual entry
  subnets_cidr                    = ["10.222.10.0/24", "10.222.20.0/24", "10.222.30.0/24"]
  subnets_map_public_ip_on_launch = false
  additional_security_group_ids   = ["sg-XXXXXXXX"]     # manual entry
  subnets_route_tables            = ["${var.private_nat_route_table_ids}"]
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
    source_sg_id = "sg-XXXXXXXX"          # manual entry
    protocol     = "tcp"
    from_port    = 987
    to_port      = 987
  }
  sg_pl_cb_egress_rule {
    cidr_blocks     = "172.16.100.0/24,172.16.101.0/24"
    prefix_list_ids = "pl-XXXXXXXX"       # manual entry
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
  }
  sg_pl_cb_egress_rule {
    cidr_blocks     = ""
    prefix_list_ids = "pl-XXXXXXXX"       # manual entry
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
  }
  sg_pl_ssg_egress_rule {
    source_sg_id    = "sg-XXXXXXXX"       # manual entry
    prefix_list_ids = "pl-XXXXXXXX"       # manual entry
    protocol        = "tcp"
    from_port       = 123
    to_port         = 123
  }
  sg_pl_ssg_egress_rule {
    source_sg_id    = ""
    prefix_list_ids = "pl-XXXXXXXX"       # manual entry
    protocol        = "tcp"
    from_port       = 456
    to_port         = 456
  }
  tags {
    Environment = "TESTENV"
    Application = "TESTPROJ"
    Tier        = "PRI"
  }
}

resource "aws_route_table_association" "test-1_private-nat" {
  count          = "3"
  subnet_id      = "${module.mservice_test-1.subnet_ids[count.index]}"
  route_table_id = "${element(var.private_nat_route_table_ids, count.index)}"
}

# module "mservice_test-1" {
#   source                          = "../../terraform-microservice"
#   additional_security_group_ids   = ["${module.env_test-1.core_sg_id}"]
#   asg_size_max                    = "3"
#   asg_size_min                    = "3"
#   availability_zones              = "${module.env_test-1.azs_available_names}"
#   aws_region                      = "${module.env_test-1.aws_region}"
#   lc_ami_id                       = "ami-edb9069e"
#   lc_instance_type                = "t2.micro"
#   name                            = "test1"
#   subnets_cidr                    = ["10.222.10.0/24", "10.222.20.0/24", "10.222.30.0/24"]
#   subnets_map_public_ip_on_launch = false
#   subnets_route_tables            = ["${module.env_test-1.private_nats_ids}"]
#   vpc_id                          = "${module.vpc_test-1.vpc_id}"
#   tags {
#     Environment = "${module.vpc_test-1.environment}"
#     Application = "${module.vpc_test-1.project}"
#     Tier        = "PRI"
#   }
# }

# resource "aws_route_table_association" "test-1_private-nat" {
#   count          = "3"
#   subnet_id      = "${module.mservice_test-1.subnet_ids[count.index]}"
#   route_table_id = "${element(module.env_test-1.private_nats_ids, count.index)}"
# }
