# vcn
resource "oci_core_vcn" "vcn" {
  cidr_blocks = [var.vcn_cidr]
  dns_label      = "${local.region}${local.virtual_cloud_network}"
  compartment_id = var.network_compartment_ocid
  display_name   = "${local.region}-${local.virtual_cloud_network}"
}
#igw
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true
  display_name   = "${local.region}-${local.internet_gateway}"
}
# ngw
resource "oci_core_nat_gateway" "ngw" {
  count = var.use_ngw ? 1 : 0
  compartment_id = var.network_compartment_ocid
  vcn_id = oci_core_vcn.vcn.id
  display_name   = "${local.region}-${local.nat_gateway}"
  block_traffic = false
}
# sgw
resource "oci_core_service_gateway" "sgw" {
  count = var.use_sgw ? 1 : 0
  compartment_id = var.network_compartment_ocid
  services {
    service_id = data.oci_core_services.available_services.services[0]["id"]
  }
  vcn_id = oci_core_vcn.vcn.id
  display_name   = "${local.region}-${local.service_gateway}"
}
# sub
resource "oci_core_subnet" "sub" {
  count = length(keys(local.infra_entities_is_public))

  prohibit_public_ip_on_vnic = ! values(local.infra_entities_is_public)[count.index]
  cidr_block        = values(local.infra_entities_cidrs)[count.index]
  compartment_id    = var.network_compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "${local.region}-${keys(local.infra_entities_is_public)[count.index]}-${local.subnet}"
  dns_label         = "${local.region}${keys(local.infra_entities_is_public)[count.index]}${local.subnet}"
  security_list_ids = [oci_core_security_list.sl[count.index].id]
  route_table_id    = oci_core_route_table.rt[count.index].id
}
# rt
resource "oci_core_route_table" "rt" {
  count = length(keys(local.infra_entities_is_public))

  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name = "${local.region}-${keys(local.infra_entities_is_public)[count.index]}-${local.route_table}"
  # route rule for igw (for public subnets)
  dynamic route_rules {
    # if public, then add internet gateway and open ingress to public internet
    for_each = values(local.infra_entities_is_public)[count.index] ? [1] : []
    content { 
      network_entity_id = oci_core_internet_gateway.igw.id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }
  # route rule for ngw (for private subnets)
  dynamic route_rules {
    for_each = var.use_ngw && (! values(local.infra_entities_is_public)[count.index]) ? [1] : []
    content { 
      network_entity_id = oci_core_nat_gateway.ngw[0].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }
  # route rule for sgw (for private subnets)
  dynamic route_rules {
    for_each = var.use_sgw && (! values(local.infra_entities_is_public)[count.index]) ? [1] : []
    content { 
      network_entity_id = oci_core_service_gateway.sgw[0].id
      destination       = data.oci_core_services.available_services.services.0.cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
    }
  }
}
# sl
resource "oci_core_security_list" "sl" {
  count = length(keys(local.infra_entities_is_public))

  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.region}-${keys(local.infra_entities_is_public)[count.index]}-${local.security_list}"

  # tcp open for ports 22, 80, 443, 3080 and 3306.

  # outbound traffic
  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
  }
  # inbound traffic
  ingress_security_rules {
    protocol = 6
    source   = values(local.infra_entities_is_public)[count.index] ? "0.0.0.0/0" : oci_core_vcn.vcn.cidr_blocks[0]

    tcp_options {
      # ssh
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = values(local.infra_entities_is_public)[count.index] ? "0.0.0.0/0" : oci_core_vcn.vcn.cidr_blocks[0]

    tcp_options {
      # http
      max = 80
      min = 80
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = values(local.infra_entities_is_public)[count.index] ? "0.0.0.0/0" : oci_core_vcn.vcn.cidr_blocks[0]

    tcp_options {
      # https
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = values(local.infra_entities_is_public)[count.index] ? "0.0.0.0/0" : oci_core_vcn.vcn.cidr_blocks[0]

    tcp_options {
      # information
      max = 3080
      min = 3080
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = values(local.infra_entities_is_public)[count.index] ? "0.0.0.0/0" : oci_core_vcn.vcn.cidr_blocks[0]

    tcp_options {
      # mysql
      max = 3306
      min = 3306
    }
  }
}