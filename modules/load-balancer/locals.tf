locals {
lb_display_names_and_ocids = {
    for i in oci_load_balancer_load_balancer.lb :
    i.display_name => i.id
  }
lb_display_names_and_ip_address_details = {
    for i in oci_load_balancer_load_balancer.lb :
    i.display_name => i.ip_address_details
  }
}