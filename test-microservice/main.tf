provider "aws" {
  region = "eu-west-1"
}

# STATIC VARIABLES ################################################################################################

variable "s3_prefix_list_id" {        
  default = "pl-6da54004"         # <= FILL IN ! shouldn't be changing for eu-west-1 region (just to test sg rules)
}
variable "ami_id" {
  default = "ami-edb9069e"        # <= FILL IN ! an ami you have access to
}
variable "example_sg_id" {
  default = "sg-75102212"         # <= FILL IN ! ex. core security group id (just to test sg rules)
}

# REMOTE STATES ###################################################################################################

data "terraform_remote_state" "bootstrap" {
    backend = "_local"
    config {
        path = "../test-bootstrap/terraform.tfstate"
    }
}

data "terraform_remote_state" "environment" {
    backend = "_local"
    config {
        path = "../test-environment/terraform.tfstate"
    }
}

# PARTY ###########################################################################################################

module "mservice_test-1" {
  source                          = "../../terraform-microservice"
  name                            = "test-1"
  vpc_id                          = "${data.terraform_remote_state.bootstrap.vpc_id}"
  asg_size_min                    = "1"
  asg_size_max                    = "2"
  asg_load_balancers              = ["${aws_elb.elb.name}"]       # optional => see elb resource below
  availability_zones              = ["${data.terraform_remote_state.bootstrap.availability_zones}"]
  aws_region                      = "eu-west-1"
  lc_ami_id                       = "${var.ami_id}"
  lc_instance_type                = "t2.micro"
  subnets_cidr                    = ["10.222.10.0/24", "10.222.20.0/24", "10.222.30.0/24"]
  subnets_map_public_ip_on_launch = false
  additional_security_group_ids   = ["${data.terraform_remote_state.environment.core_sg_id}"]
  subnets_route_tables            = ["${data.terraform_remote_state.bootstrap.private_nat_route_table_ids}"]
  sg_cb_ingress_rule {                                            # optional example
    cidr_blocks = "172.16.100.0/24,172.16.101.0/24"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }
  sg_cb_ingress_rule {                                            # optional example
    cidr_blocks = "172.16.100.0/24,172.16.101.0/24"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }
  sg_ssg_ingress_rule {                                           # optional example
    source_sg_id = "${var.example_sg_id}"
    protocol     = "tcp"
    from_port    = 987
    to_port      = 987
  }
  sg_pl_cb_egress_rule {                                          # optional example
    cidr_blocks     = "172.16.100.0/24,172.16.101.0/24"
    prefix_list_ids = "${var.s3_prefix_list_id}"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
  }
  sg_pl_cb_egress_rule {                                          # optional example
    cidr_blocks     = ""
    prefix_list_ids = "${var.s3_prefix_list_id}"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
  }
  sg_pl_ssg_egress_rule {                                         # optional example
    source_sg_id    = "${var.example_sg_id}"
    prefix_list_ids = "${var.s3_prefix_list_id}"
    protocol        = "tcp"
    from_port       = 123
    to_port         = 123
  }
  sg_pl_ssg_egress_rule {                                         # optional example
    source_sg_id    = ""
    prefix_list_ids = "${var.s3_prefix_list_id}"
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
  route_table_id = "${element(data.terraform_remote_state.bootstrap.private_nat_route_table_ids, count.index)}"
}

resource "aws_elb" "elb" {
  name                        = "test-1-elb"
  internal                    = true
  subnets                     = ["${module.mservice_test-1.subnet_ids}"]
  security_groups             = ["${module.mservice_test-1.security_group_id}"]
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    target              = "TCP:80"
    interval            = 30
  }
  tags {
    Environment = "TESTENV"
    Application = "TESTPROJ"
  }
}

resource "aws_route53_record" "elb-alias" {
  zone_id = "${data.terraform_remote_state.bootstrap.private_hosted_zone_id}"
  name    = "${aws_elb.elb.name}"
  type    = "A"
  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = true
  }
}
