module "network" {
  source = "./modules/network"
  # configuration
  network_compartment_ocid = var.network_compartment_ocid
  vcn_cidr = var.vcn_cidr
  use_ngw = var.use_ngw
  use_sgw = var.use_sgw
  compute_and_load_balancer_specs = local.compute_and_load_balancer_specs
  deploy_fss = var.deploy_fss
  # naming convention
  region_key = local.region_key
  virtual_cloud_network = local.virtual_cloud_network
  internet_gateway = local.internet_gateway
  nat_gateway = local.nat_gateway
  service_gateway = local.service_gateway
  security_list = local.security_list
  route_table = local.route_table
  subnet = local.subnet
  file_storage_service = local.file_storage_service
}
module "compute" {
  depends_on = [module.load-balancer]
  count = var.deploy_compute ? 1 : 0
  source = "./modules/compute"
  # configuration
  compute_compartment_ocid = var.compute_compartment_ocid
  ssh_public_key = var.ssh_public_key
  compute_shape = var.compute_shape
  compute_shape_config_memory_in_gbs = var.compute_shape_config_memory_in_gbs
  compute_shape_config_ocpus = var.compute_shape_config_ocpus
  region = var.region
  tf_generated_ssh_key_pub = tls_private_key.ssh.public_key_openssh
  tf_generated_ssh_key = tls_private_key.ssh.private_key_pem
  backend_port = var.backend_port
  computes_load_balanced = local.computes_load_balanced
  computes_load_balanced_and_load_balancer = local.computes_load_balanced_and_load_balancer
  deploy_load_balancer = var.deploy_load_balancer
  instance_pool_node_count_initial = var.instance_pool_node_count_initial
  mount_target_private_ip = var.deploy_fss ? module.file-storage[0].mount_target_private_ip : null
  fss_export_path = var.fss_export_path
  deploy_fss = var.deploy_fss
  enable_is_bootstrapped_fss = var.enable_is_bootstrapped_fss
  enable_is_bootstrapped_http_server = var.enable_is_bootstrapped_http_server
  http_app_tar_file_url = var.http_app_tar_file_url
  enable_is_bootstrapped_ssh_key = var.enable_is_bootstrapped_ssh_key
  enable_is_bootstrapped_vnc_server = var.enable_is_bootstrapped_vnc_server
  vncpasswd = var.vncpasswd
  computes_pool_specs = local.computes_pool_specs
  computes_solo_specs = local.computes_solo_specs
  lb_display_names_and_ocids = var.deploy_load_balancer ? module.load-balancer[0].lb_display_names_and_ocids : null
  subnet_display_names_and_ocids = module.network.subnet_display_names_and_ocids
  # naming convention
  region_key = local.region_key
  ad_name = local.ad_name
  fd_names = local.fd_names
  compute_collective_specs = local.compute_collective_specs
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
  compute_collective_specs = local.compute_collective_specs
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
  auto_scaling_configuration_cool_down_in_seconds = var.auto_scaling_configuration_cool_down_in_seconds
  computes_pool_specs = local.computes_pool_specs
  computes_solo_specs = local.computes_solo_specs
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
  listener_connection_configuration_idle_timeout_in_seconds = var.listener_connection_configuration_idle_timeout_in_seconds
  load_balancer_specs = local.load_balancer_specs
  subnet_display_names_and_ocids = module.network.subnet_display_names_and_ocids
  # naming convention
  region_key = local.region_key
  load_balancer = local.load_balancer
  subnet = local.subnet
  load_balancer_backend_set = local.load_balancer_backend_set
  load_balancer_listener = local.load_balancer_listener
}
module "file-storage" {
  count = var.deploy_fss ? 1 : 0
  source = "./modules/file-storage"
  # configuration
  fss_compartment_ocid = var.fss_compartment_ocid
  ad_name = local.ad_name
  subnet_display_names_and_ocids = module.network.subnet_display_names_and_ocids
  vcn_ocid = module.network.vcn_ocid
  vcn_cidr = var.vcn_cidr
  fss_export_path = var.fss_export_path
  subnet_cidr_fss = var.subnet_cidr_fss
  # naming convention
  region_key = local.region_key
  filesystem = local.filesystem
  file_storage_service = local.file_storage_service
  mount_target = local.mount_target
  subnet = local.subnet
  security_list = local.security_list
}