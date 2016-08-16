module "mservice_test-1" {
  source                          = "../../terraform-microservice"
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
