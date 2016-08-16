module "vpc_test-1" {
  source              = "../../terraform-bootstrap"
  environment         = "env1"
  project             = "project"
  vpc_cidr            = "10.0.0.0/16"
  private_dns_domain  = "env1.project.aws.test"
}

module "vpc_test-2" {
  source              = "../../terraform-bootstrap"
  environment         = "env2"
  project             = "project"
  vpc_cidr            = "172.16.0.0/16"
  private_dns_domain  = "env2.project.aws.test"
  peer_matrix         = ["012345678901,vpc-00000000,10.0.0.0/16"] # would like to have vars here
}
