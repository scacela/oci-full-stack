# configuration
variable "load_balancer_compartment_ocid" {}
variable "backend_set_health_checker_protocol" {}
variable "load_balancer_health_check_url_path" {}
variable "load_balancer_shape" {}
variable "listener_protocol" {}
variable "listener_port" {}
variable "backend_set_policy" {}
variable "listener_connection_configuration_idle_timeout_in_seconds" {}
variable "load_balancer_specs" {}
variable "subnet_display_names_and_ocids" {}
# naming convention
variable "region_key" {}
variable "load_balancer" {}
variable "subnet" {}
variable "load_balancer_backend_set" {}
variable "load_balancer_listener" {}