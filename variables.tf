# common
variable "region" {}
# network
variable "network_compartment_ocid" {}
variable "vcn_cidr" { default = "10.0.0.0/16" }
variable "subnet_cidr_lbweb" { default = "10.0.0.0/24" }
variable "subnet_cidr_web" { default = "10.0.1.0/24" }
variable "subnet_cidr_lbapp" { default = "10.0.2.0/24" }
variable "subnet_cidr_app" { default = "10.0.3.0/24" }
variable "subnet_cidr_db" { default = "10.0.4.0/24" }
variable "use_ngw" { default = true }
variable "use_sgw" { default = true }
# compute
variable "deploy_compute" { default = true }
variable "compute_compartment_ocid" {}
variable "ad_number" { default = 1 }
variable "instance_configuration_shape" { default = "VM.Standard2.1" }
variable "instance_configuration_ssh_public_key" { default = "" }
variable "instance_configuration_shape_config_memory_in_gbs" { default = 32 }
variable "instance_configuration_shape_config_ocpus" { default = 8 }
variable "instance_pool_node_count_initial" { default = 1 }
variable "oracle_linux_os_version" { default = "7.9" }
# bastion
variable "use_bastion" {default = true }
variable "subnet_cidr_bastion" { default = "10.0.5.0/24" }
variable "bastion_oracle_linux_os_version" { default = "7.9" }
variable "bastion_shape" { default = "VM.Standard2.1" }
# autoscale
variable "deploy_autoscaling" { default = true }
variable "autoscaling_compartment_ocid" { default = "" }
variable "autoscaling_policy_type" { default = "threshold" }
variable "autoscaling_node_count_initial" { default = 2 }
variable "autoscaling_node_count_max" { default = 4 }
variable "autoscaling_node_count_min" { default = 2 }
variable "scale_in_action_type" { default = "CHANGE_COUNT_BY" }
variable "scale_in_action_value" { default = -1 }
variable "scale_in_metric_type" { default = "CPU_UTILIZATION" }
variable "scale_in_threshold_operator" { default = "LT" }
variable "scale_in_threshold_value" { default = 10  }
variable "scale_out_action_type" { default = "CHANGE_COUNT_BY" }
variable "scale_out_action_value" { default = 1 }
variable "scale_out_metric_type" { default = "CPU_UTILIZATION" }
variable "scale_out_threshold_operator" { default = "GT" }
variable "scale_out_threshold_value" { default = 50  }
# load balancer
variable "deploy_load_balancer" { default = true }
variable "load_balancer_compartment_ocid" { default = "" }
variable "load_balancer_shape" { default = "10Mbps" }
variable "backend_set_health_checker_protocol" { default = "TCP" }
variable "backend_set_policy" { default = "ROUND_ROBIN" }
variable "backend_port" { default = 80 }
variable "listener_port" { default = 80 }
variable "listener_protocol" { default = "TCP" }
variable "load_balancer_health_check_url_path" { default = "/" }
# file storage
variable "deploy_fss" { default = true }
variable "fss_compartment_ocid" { default = "" }
variable "fss_export_path" { default = "/FSS" }
variable "subnet_cidr_fss" { default = "10.0.6.0/24" }