# set   TF_VAR_ variables: $ source env.sh
# unset TF_VAR_ variables: $ unset ${!TF_VAR_@}
# inspect TF_VAR_ variables: $ env | grep TF_VAR_

# authorization
export TF_VAR_tenancy_ocid=YOUR_TENANCY_OCID
export TF_VAR_user_ocid=YOUR_USER_OCID
export TF_VAR_fingerprint=YOUR_FINGERPRINT
export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
export TF_VAR_region=us-phoenix-1
# network
export TF_VAR_network_compartment_ocid=YOUR_COMPARTMENT_OCID
export TF_VAR_vcn_cidr="10.0.0.0/16"
export TF_VAR_subnet_cidr_lbweb="10.0.0.0/24"
export TF_VAR_subnet_cidr_web="10.0.1.0/24"
export TF_VAR_subnet_cidr_lbapp="10.0.2.0/24"
export TF_VAR_subnet_cidr_app="10.0.3.0/24"
export TF_VAR_subnet_cidr_db="10.0.4.0/24"
export TF_VAR_use_ngw=true
export TF_VAR_use_sgw=true
# compute
export TF_VAR_deploy_compute=true
export TF_VAR_compute_compartment_ocid=YOUR_COMPARTMENT_OCID
export TF_VAR_ad_number=1
export TF_VAR_compute_shape="VM.Standard2.1"
export TF_VAR_ssh_public_key=YOUR_SSH_PUBLIC_KEY_CONTENT
export TF_VAR_compute_shape_config_memory_in_gbs=32
export TF_VAR_compute_shape_config_ocpus=8
export TF_VAR_instance_pool_node_count_initial=1
export TF_VAR_compute_oracle_linux_os_version=7.9
export TF_VAR_enable_is_bootstrapped_http_server=true
export TF_VAR_http_app_tar_file_url=YOUR_HTTP_APP_TAR_FILE_URL
export TF_VAR_enable_is_bootstrapped_ssh_key=true
export TF_VAR_enable_is_bootstrapped_vnc_server=true
export TF_VAR_vncpasswd="fullstack1"
# bastion
export TF_VAR_deploy_bastion=true
export TF_VAR_subnet_cidr_bastion="10.0.5.0/24"
export TF_VAR_bastion_oracle_linux_os_version="7.9"
export TF_VAR_bastion_shape="VM.Standard2.1"
export TF_VAR_bastion_shape_config_memory_in_gbs=32
export TF_VAR_bastion_shape_config_ocpus=8
# autoscale
export TF_VAR_deploy_autoscaling=true
export TF_VAR_autoscaling_compartment_ocid=YOUR_COMPARTMENT_OCID
export TF_VAR_autoscaling_node_count_max=4
export TF_VAR_autoscaling_node_count_min=1
export TF_VAR_scale_in_action_value=-1
export TF_VAR_scale_in_metric_type=CPU_UTILIZATION
export TF_VAR_scale_in_threshold_operator="LT"
export TF_VAR_scale_in_threshold_value=10
export TF_VAR_scale_out_action_value=1
export TF_VAR_scale_out_metric_type=CPU_UTILIZATION
export TF_VAR_scale_out_threshold_operator="GT"
export TF_VAR_scale_out_threshold_value=50
export TF_VAR_auto_scaling_configuration_cool_down_in_seconds=300
# load balancer
export TF_VAR_deploy_load_balancer=true
export TF_VAR_load_balancer_compartment_ocid=YOUR_COMPARTMENT_OCID
export TF_VAR_load_balancer_shape="10Mbps"
export TF_VAR_backend_set_health_checker_protocol="TCP"
export TF_VAR_backend_set_policy="ROUND_ROBIN"
export TF_VAR_backend_port=80
export TF_VAR_listener_port=80
export TF_VAR_listener_protocol="TCP"
export TF_VAR_load_balancer_health_check_url_path="/"
export TF_VAR_listener_connection_configuration_idle_timeout_in_seconds=300
# file storage
export TF_VAR_deploy_fss=true
export TF_VAR_fss_compartment_ocid=YOUR_COMPARTMENT_OCID
export TF_VAR_fss_export_path="/FSS"
export TF_VAR_subnet_cidr_fss="10.0.6.0/24"
export TF_VAR_enable_is_bootstrapped_fss=true