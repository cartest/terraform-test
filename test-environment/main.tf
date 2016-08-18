module "env_test-1" {
  source                          = "../../terraform-environment"
  environment                     = "testenv"
  project                         = "testproj"
  aws_region                      = "eu-west-1"
  vpc_id                          = "vpc-00000000000000000"
  bootstrap_public_route_table_id = "rtb-00000000000000000"
  internet_gateway_id             = "igw-00000000000000000"
  example_bucket_name             = "iamabucket"
}
