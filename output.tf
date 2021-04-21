# private ssh key of Terraform-generated ssh key pair
output "tf_generated_ssh_key" {
  value = tls_private_key.ssh.private_key_pem
}
output "compute_image" {
  # first element for latest version
  value = var.deploy_compute ? data.oci_core_images.compute_images.images[0].display_name : null
}
output "bastion_image" {
  value = local.deploy_bastion ? data.oci_core_images.bastion_images.images[0].display_name : null
}
output "bastion_public_ip" {
  value = local.deploy_bastion ? module.bastion[0].public_ip : null
}