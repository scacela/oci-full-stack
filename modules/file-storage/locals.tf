# helper
locals {
  mount_target_private_ip_ids_elem = oci_file_storage_mount_target.mount_target.private_ip_ids[0]
  mount_target_private_ip = data.oci_core_private_ip.mount_target_private_ip.ip_address
}

