# resources:
# lb, lb_backend_set

# lb
resource "oci_load_balancer_load_balancer" "lb" {
  count = length(var.load_balancer_specs)

  is_private = ! var.load_balancer_specs[keys(var.load_balancer_specs)[count.index]].is_public
  display_name = "${var.region_key}-${keys(var.load_balancer_specs)[count.index]}-${var.load_balancer}"
  compartment_id = var.load_balancer_compartment_ocid
  shape          = var.load_balancer_shape
  subnet_ids = [var.subnet_display_names_and_ocids["${var.region_key}-${keys(var.load_balancer_specs)[count.index]}-${var.subnet}"]]
}
# lb_backend_set
resource "oci_load_balancer_backend_set" "lb_backend_set" {
  count = length(var.load_balancer_specs)

  health_checker {
    protocol = var.backend_set_health_checker_protocol
    url_path = var.load_balancer_health_check_url_path
  }

  load_balancer_id = oci_load_balancer_load_balancer.lb[count.index].id
  name             = "${var.region_key}-${keys(var.load_balancer_specs)[count.index]}-${var.load_balancer_backend_set}"
  policy           = var.backend_set_policy
}

resource "oci_load_balancer_listener" "lb_listener" {
    count = length(var.load_balancer_specs)
    default_backend_set_name = oci_load_balancer_backend_set.lb_backend_set[count.index].name
    load_balancer_id = oci_load_balancer_load_balancer.lb[count.index].id
    name = "${var.region_key}-${keys(var.load_balancer_specs)[count.index]}-${var.load_balancer_listener}"
    port = var.listener_port
    protocol = var.listener_protocol
    connection_configuration {
      idle_timeout_in_seconds = var.listener_connection_configuration_idle_timeout_in_seconds
    }
}