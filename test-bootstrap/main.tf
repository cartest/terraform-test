module "bootstrap_test" {
  source               = "../../terraform-bootstrap"
  environment          = "TESTENV"
  project              = "TESTPROJ"
  vpc_cidr             = "10.222.0.0/16"
  private_dns_domain   = "testdomain.mot.aws.dvsa"
  ha-nat_subnets_cidrs = ["10.222.1.0/24", "10.222.2.0/24", "10.222.3.0/24"]
}
