locals {
lb_displaynames_and_ocids = {
    for i in oci_load_balancer_load_balancer.lb :
    i.display_name => i.id
  }
}