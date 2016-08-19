output "vpc_test-1_id" {
  value = "${module.vpc_test-1.vpc_id}"
}

output "vpc_test-2_id" {
  value = "${module.vpc_test-2.vpc_id}"
}

output "vpc_test-2_peering_ids" {
  value = ["${module.vpc_test-2.vpc_peering_ids}"]
}
