locals {
subnet_displaynames_and_ocids = {
    for i in oci_core_subnet.sub :
    i.display_name => i.id
  }
}