output "instance_pool_ocids" {
  value = oci_core_instance_pool.pool.*.id
}