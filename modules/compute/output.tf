output "instance_pool_ocids" {
  value = oci_core_instance_pool.pool.*.id
}
output "ssh_key" {
  value = tls_private_key.ssh.private_key_pem
}