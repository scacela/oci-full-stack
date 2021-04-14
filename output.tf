# locals {
#   compute_info = {
#     public_ips = oci_core_instance.compute.*.public_ip
#     private_ips = oci_core_instance.compute.*.private_ip
#     display_names = oci_core_instance.compute.*.display_name
#   }
# }
# output "compute_info" {
#   value = local.compute_info
# }
output "ssh_key" {
  value = tls_private_key.ssh.private_key_pem
}