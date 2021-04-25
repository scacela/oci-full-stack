locals {
solo_computes_display_names_and_public_ips = {
    for i in oci_core_instance.compute :
    i.display_name => i.public_ip
  }
}