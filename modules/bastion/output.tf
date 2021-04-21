output "public_ip" {
  value = oci_core_instance.compute.public_ip
}
output "subnet_ocid" {
  value = oci_core_subnet.sub.id
}