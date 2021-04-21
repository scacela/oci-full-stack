# configuration
variable "compute_compartment_ocid" {}
variable "network_compartment_ocid" {}
variable "bastion_shape" {}
variable "bastion_image_ocid" {}
variable "tf_generated_ssh_key_pub" {}
variable "subnet_cidr_bastion" {}
variable "vcn_ocid" {}
variable "igw_ocid" {}
variable "ad_name" {}
variable "instance_configuration_ssh_public_key" {}
# naming conventions
variable "region_key" {}
variable "subnet" {}
variable "security_list" {}
variable "internet_gateway" {}
variable "route_table" {}
variable "bastion" {}