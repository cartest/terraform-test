module "env_test-1" {
  source                          = "../../terraform-environment"
  environment                     = "${module.vpc_test-1.environment}"
  project                         = "${module.vpc_test-1.project}"
  aws_region                      = "${module.vpc_test-1.aws_region}"
  vpc_id                          = "${module.vpc_test-1.vpc_id}"
  bootstrap_public_route_table_id = "rtb-00000000"  # didn't work with variable passwed from boostrap module
  internet_gateway_id             = "${module.vpc_test-1.internet_gateway_id}"
  #example_bucket_name             = "shakalaka"  # optional
}

module "env_test-2" {
  source                          = "../../terraform-environment"
  environment                     = "${module.vpc_test-2.environment}"
  project                         = "${module.vpc_test-2.project}"
  aws_region                      = "${module.vpc_test-2.aws_region}"
  vpc_id                          = "${module.vpc_test-2.vpc_id}"
  bootstrap_public_route_table_id = "rtb-e50d7281"
  internet_gateway_id             = "${module.vpc_test-2.internet_gateway_id}"
  #example_bucket_name             = "shakalaka"  # optional
}
