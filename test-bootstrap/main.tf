module "bootstrap_test" {
  source               = "../../terraform-bootstrap"
  environment          = "TESTENV"
  project              = "TESTPROJ"
  vpc_cidr             = "10.222.0.0/16"
  private_dns_domain   = "testdomain.mot.aws.dvsa"
  ha-nat_subnets_cidrs = ["10.222.1.0/24", "10.222.2.0/24", "10.222.3.0/24"]
}

# module "bootstrap_test2" {
#   source               = "../../terraform-bootstrap"
#   environment          = "TESTENV2"
#   project              = "TESTPROJ2"
#   vpc_cidr             = "172.16.0.0/16"
#   private_dns_domain   = "testdomain2.mot.aws.dvsa"
#   ha-nat_subnets_cidrs = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
#   peer_matrix          = ["<your account>,<first vpc>,10.222.0.0/16"]            # manual entries
#   peering_connections  = "${module.bootstrap_test2.vpc_peering_ids}"
# }
