# private ssh key of Terraform-generated ssh key pair
output "tf_generated_ssh_key" {
  value = module.compute.*.ssh_key
}
output "compute_image" {
  # first element for latest version
  value = data.oci_core_images.compute_images.images[0].display_name
}