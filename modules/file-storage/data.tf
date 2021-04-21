data "oci_core_private_ip" "mount_target_private_ip" {
  private_ip_id = local.mount_target_private_ip_ids_elem
}