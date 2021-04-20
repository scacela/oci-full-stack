# to do:

# DONE in modules.tf: set up module attributes each module type
# DONE in each module folder:
  # DONE change local. to var. for most values
  # DONE populate variables.tf using regex
  # DONE set up output objects so that modules can get values from other modules
# DONE add new variables that are currently hardcoded
# DONE add new variables to variable intake files (env.sh, myenv.sh, schema.yaml)
# add to readme with CLI and resource manager deployment instructions
# DONE use OL 7.9 image

module "network" {
  source = "./modules/network"
  # configuration
  network_compartment_ocid = var.network_compartment_ocid
  vcn_cidr = var.vcn_cidr
  use_ngw = var.use_ngw
  use_sgw = var.use_sgw
  compute_and_load_balancer_specs = local.compute_and_load_balancer_specs
  # naming convention
  region_key = local.region_key
  virtual_cloud_network = local.virtual_cloud_network
  internet_gateway = local.internet_gateway
  nat_gateway = local.nat_gateway
  service_gateway = local.service_gateway
  security_list = local.security_list
  route_table = local.route_table
  subnet = local.subnet
}

module "compute" {
  depends_on = [module.load-balancer]
  count = var.deploy_compute ? 1 : 0
  source = "./modules/compute"
  # configuration
  compute_compartment_ocid = var.compute_compartment_ocid
  instance_configuration_ssh_public_key = var.instance_configuration_ssh_public_key
  instance_configuration_shape = var.instance_configuration_shape
  instance_configuration_shape_config_memory_in_gbs = var.instance_configuration_shape_config_memory_in_gbs
  instance_configuration_shape_config_ocpus = var.instance_configuration_shape_config_ocpus
  region = var.region
  backend_port = var.backend_port
  compute_load_balanced = local.compute_load_balanced
  compute_load_balanced_and_load_balancer = local.compute_load_balanced_and_load_balancer
  deploy_load_balancer = var.deploy_load_balancer
  instance_pool_node_count_initial = var.instance_pool_node_count_initial
  image_ocid = local.image_ocid
  lb_displaynames_and_ocids = var.deploy_load_balancer ? module.load-balancer[0].lb_displaynames_and_ocids : null
  subnet_displaynames_and_ocids = module.network.subnet_displaynames_and_ocids
  # naming convention
  region_key = local.region_key
  ad_name = local.ad_name
  fd_names = local.fd_names
  compute_specs = local.compute_specs
  instance_configuration = local.instance_configuration
  compute_instance = local.compute_instance
  subnet = local.subnet
  load_balancer = local.load_balancer
  load_balancer_backend_set = local.load_balancer_backend_set
  instance_pool = local.instance_pool
}

module "autoscale" {
  count = var.deploy_compute && var.deploy_autoscaling ? 1 : 0
  source = "./modules/autoscale"
  # configuration
  autoscaling_compartment_ocid = var.autoscaling_compartment_ocid
  compute_specs = local.compute_specs
  autoscaling_policy_type = var.autoscaling_policy_type
  # autoscaling_node_count_initial = var.autoscaling_node_count_initial
  autoscaling_node_count_initial = var.instance_pool_node_count_initial
  autoscaling_node_count_max = var.autoscaling_node_count_max
  autoscaling_node_count_min = var.autoscaling_node_count_min
  scale_in_action_type = var.scale_in_action_type
  scale_in_action_value = var.scale_in_action_value
  scale_in_metric_type = var.scale_in_metric_type
  scale_in_threshold_operator = var.scale_in_threshold_operator
  scale_in_threshold_value = var.scale_in_threshold_value
  scale_out_action_type = var.scale_out_action_type
  scale_out_action_value = var.scale_out_action_value
  scale_out_metric_type = var.scale_out_metric_type
  scale_out_threshold_operator = var.scale_out_threshold_operator
  scale_out_threshold_value = var.scale_out_threshold_value
  instance_pool_ocids = module.compute[0].instance_pool_ocids
  # naming convention
  region_key = local.region_key
  autoscaling_configuration = local.autoscaling_configuration
  compute_instance = local.compute_instance
}

module "load-balancer" {
  count = var.deploy_load_balancer ? 1 : 0
  source = "./modules/load-balancer"
  # configuration
  load_balancer_compartment_ocid = var.load_balancer_compartment_ocid
  backend_set_health_checker_protocol = var.backend_set_health_checker_protocol
  load_balancer_health_check_url_path = var.load_balancer_health_check_url_path
  load_balancer_shape = var.load_balancer_shape
  listener_protocol = var.listener_protocol
  listener_port = var.listener_port
  backend_set_policy = var.backend_set_policy
  load_balancer_specs = local.load_balancer_specs
  subnet_displaynames_and_ocids = module.network.subnet_displaynames_and_ocids
  # naming convention
  region_key = local.region_key
  load_balancer = local.load_balancer
  subnet = local.subnet
  load_balancer_backend_set = local.load_balancer_backend_set
  load_balancer_listener = local.load_balancer_listener
}