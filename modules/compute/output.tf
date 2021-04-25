output "instance_pool_ocids" {
  value = oci_core_instance_pool.pool.*.id
}
output "solo_computes_display_names_and_public_ips" {
  value = local.solo_computes_display_names_and_public_ips
}