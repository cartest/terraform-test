provider "aws" {
  region = "eu-west-1"
}

# STEP 2: Create bootstrap env
module bootstrap_env01 {
  source = "git::https://github.com/cartest/terraform-buildtools?ref=dawidm/tests"
  vpc_cidr = "10.223.0.0/16"
  environment = "env01"
  ha-nat_subnets_cidrs = ["10.223.1.0/16"]
  project = "mot2"
  private_dns_domain = "mot2-env01-domain"
  build_tools_tf_state = "../step1/terraform.tfstate"
}
