# ssh private key of the generated ssh key pair
output "tf_generated_ssh_key" {
  value = tls_private_key.ssh.private_key_pem
}
output "compute_image" {
  value = var.deploy_compute ? data.oci_core_images.compute_images.images[0].display_name : null
}
output "bastion_image" {
  value = local.deploy_bastion ? data.oci_core_images.bastion_images.images[0].display_name : null
}
output "solo_computes_display_names_and_public_ips" {
  value = var.deploy_compute ? module.compute[0].solo_computes_display_names_and_public_ips : null
}
output "load_balancer_display_names_and_ip_address_details" {
  value = var.deploy_load_balancer ? module.load-balancer[0].lb_display_names_and_ip_address_details : null
}