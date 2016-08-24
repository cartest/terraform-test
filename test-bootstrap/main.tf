variable "environment" {
  type        = "string"
  description = "Environment Name"
  default     = "testenv"
}

variable "project" {
  type        = "string"
  description = "Project Name"
  default     = "testproj"
}

variable "vpc_cidr" {
  type        = "string"
  description = "VPC CIDR Block"
  default     = "10.0.0.0/16"
}

variable "private_dns_domain" {
  type        = "string"
  description = "Private Hosted Zone DNS Domain Name"
  default     = "testenv.testproj.aws.test"
}

module "bootstrap_test" {
  source             = "../../terraform-bootstrap"
  environment        = "${var.environment}"
  project            = "${var.project}"
  vpc_cidr           = "${var.vpc_cidr}"
  private_dns_domain = "${var.private_dns_domain}"
}
