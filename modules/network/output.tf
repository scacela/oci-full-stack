output "subnet_displaynames_and_ocids" {
  value = local.subnet_displaynames_and_ocids
}
output "vcn_ocid" {
  value = oci_core_vcn.vcn.id
}
output "igw_ocid" {
  value = oci_core_internet_gateway.igw.id
}