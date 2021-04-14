# set   TF_VAR_ variables: $ source env.sh
# unset TF_VAR_ variables: $ unset ${!TF_VAR_@}
# inspect TF_VAR_ variables: $ env | grep TF_VAR_
export TF_VAR_tenancy_ocid=TENANCY_OCID # replace
export TF_VAR_user_ocid=USER_OCID # replace
export TF_VAR_fingerprint=FINGERPRINT # replace
export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
export TF_VAR_region=us-phoenix-1

# common
export TF_VAR_ad_number=1
# network layer
export TF_VAR_network_compartment_ocid=COMPARTMENT_OCID # replace
export TF_VAR_vcn_cidr="10.0.0.0/16"
export TF_VAR_subnet_lb_web_cidr="10.0.0.0/24"
export TF_VAR_subnet_web_cidr="10.0.1.0/24"
export TF_VAR_subnet_lb_app_cidr="10.0.2.0/24"
export TF_VAR_subnet_app_cidr="10.0.3.0/24"
export TF_VAR_subnet_db_cidr="10.0.4.0/24"
export TF_VAR_use_ngw=true
export TF_VAR_use_sgw=true
# compute layer
export TF_VAR_deploy_compute=true
export TF_VAR_compute_compartment_ocid=COMPARTMENT_OCID # replace
export TF_VAR_compute_shape="VM.Standard2.1"
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa)
export TF_VAR_compute_shape_config_memory_in_gbs=32
export TF_VAR_compute_shape_config_ocpus=8
export TF_VAR_compute_initial_pool_size=0