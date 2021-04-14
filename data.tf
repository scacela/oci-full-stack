data "oci_identity_availability_domains" "compute_ads" {
  compartment_id = var.compute_compartment_ocid
}
data "oci_identity_regions" "available_regions" {
  filter {
    name = "name"
    values = [var.region]
    regex = false
  }
}
data "oci_core_services" "available_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}