data "terraform_remote_state" "bootstrap" {
    backend = "_local"
    config {
        path = "../test-bootstrap/terraform.tfstate"
    }
}

module "env_test-1" {
  source       = "../../terraform-environment"
  environment  = "testenv"
  project      = "testproj"
  aws_region   = "eu-west-1"
  vpc_id       = "${data.terraform_remote_state.bootstrap.vpc_id}"       # manual entry
  #bucket_name = "iamabucket"                                             # optional entry
}
