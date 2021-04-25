# availability domains
data "oci_identity_availability_domains" "compute_ads" {
  compartment_id = var.compute_compartment_ocid
}
# fault domains
data "oci_identity_fault_domains" "compute_fds" {
    availability_domain = local.ad_name
    compartment_id = var.compute_compartment_ocid
}
# regions
data "oci_identity_regions" "available_regions" {
  filter {
    name = "name"
    values = [var.region]
    regex = false
  }
}
# images (compute)
data "oci_core_images" "compute_images" {
    compartment_id = var.compute_compartment_ocid
    operating_system = "Oracle Linux"
    operating_system_version = var.compute_oracle_linux_os_version
    shape = var.compute_shape
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}
# images (bastion)
data "oci_core_images" "bastion_images" {
    compartment_id = var.compute_compartment_ocid
    operating_system = "Oracle Linux"
    operating_system_version = var.bastion_oracle_linux_os_version
    shape = var.bastion_shape
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}