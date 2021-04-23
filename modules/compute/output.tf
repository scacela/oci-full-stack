output "instance_pool_ocids" {
  value = oci_core_instance_pool.pool.*.id
}
output "fss" {
  value = data.template_file.bootstrap_fss[0].rendered
}
output "all" {
  value = data.template_cloudinit_config.bootstrap.rendered
}