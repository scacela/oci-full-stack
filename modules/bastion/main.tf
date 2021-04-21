# resources:
# compute, subnet, sl, rt

# compute
resource "oci_core_instance" "compute" {
  availability_domain = var.ad_name
  compartment_id = var.compute_compartment_ocid
  display_name = "${var.region_key}-${var.bastion}"
  shape          = var.bastion_shape
  create_vnic_details {
    subnet_id        = oci_core_subnet.sub.id
    assign_public_ip = true
    hostname_label   = "${var.region_key}-${var.bastion}"
  }
  source_details {
    source_type = "image"
    source_id   = var.bastion_image_ocid
  }
  metadata = {
    ssh_authorized_keys = "${var.instance_configuration_ssh_public_key}\n${var.tf_generated_ssh_key_pub}"
  }
}
# subnet for mount target
resource "oci_core_subnet" "sub" {
  prohibit_public_ip_on_vnic = false
  cidr_block        = var.subnet_cidr_bastion
  compartment_id    = var.network_compartment_ocid
  vcn_id            = var.vcn_ocid
  display_name      = "${var.region_key}-${var.bastion}-${var.subnet}"
  dns_label         = "${var.region_key}${var.bastion}${var.subnet}"
  security_list_ids = [oci_core_security_list.sl.id]
  route_table_id    = oci_core_route_table.rt.id
}
# sl
resource "oci_core_security_list" "sl" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = var.vcn_ocid
  display_name   = "${var.region_key}-${var.bastion}-${var.security_list}"

  # outbound traffic
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
  }
  # inbound traffic
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}
# rt
resource "oci_core_route_table" "rt" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = var.vcn_ocid
  display_name = "${var.region_key}-${var.bastion}-${var.route_table}"
  # route rule for igw (for public subnets)
  route_rules {
      network_entity_id = var.igw_ocid
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
  }
}