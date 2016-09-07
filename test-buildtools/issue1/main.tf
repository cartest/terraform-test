provider "aws" {
  region = "eu-west-1"
}

# STEP 1: Create build tools
module buildtools {
  source      = "git::https://github.com/cartest/terraform-buildtools?ref=dawidm/tests"
  environment = "buildtools-env"
  project     = "mot2"
  ha-nat_subnets_cidrs  = ["10.222.1.0/24", "10.222.2.0/24"]
  /*peer_matrix = ["054631451206,vpc-01234567890123456,10.99.0.0/16"]*/
  private_dns_domain = "mot2-buildtools-domain"
  vpc_cidr = "10.222.0.0/16"
}
