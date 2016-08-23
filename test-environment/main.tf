module "env_test-1" {
  source                          = "../../terraform-environment"
  environment                     = "testenv"
  project                         = "testproj"
  aws_region                      = "eu-west-1"
  vpc_id                          = "vpc-XXXXXXXX"       # manual entry
  #bucket_name                     = "iamabucket"        # optional entry
}
