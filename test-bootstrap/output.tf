output "availability_zones" {
  value = ["${module.bootstrap_test.availability_zones}"]
}

output "vpc_id" {
  value = "${module.bootstrap_test.vpc_id}"
}

output "private_nat_route_table_ids" {
  value = "${module.bootstrap_test.private_nat_route_table_ids}"
}

output "private_hosted_zone_id" {
  value = "${module.bootstrap_test.private_hosted_zone_id}"
}
