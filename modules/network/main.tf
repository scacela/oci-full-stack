# resources:
# vcn, igw, ngw, sgw, sub, rt, sl

# vcn
resource "oci_core_vcn" "vcn" {
  cidr_blocks = [var.vcn_cidr]
  dns_label      = "${var.region_key}${var.virtual_cloud_network}"
  compartment_id = var.network_compartment_ocid
  display_name   = "${var.region_key}-${var.virtual_cloud_network}"
}
# igw
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  enabled        = true
  display_name   = "${var.region_key}-${var.internet_gateway}"
}
# ngw
resource "oci_core_nat_gateway" "ngw" {
  count = var.use_ngw ? 1 : 0
  compartment_id = var.network_compartment_ocid
  vcn_id = oci_core_vcn.vcn.id
  display_name   = "${var.region_key}-${var.nat_gateway}"
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
  display_name   = "${var.region_key}-${var.service_gateway}"
}
# sub
resource "oci_core_subnet" "sub" {
  count = length(var.compute_and_load_balancer_specs)

  prohibit_public_ip_on_vnic = ! values(var.compute_and_load_balancer_specs)[count.index].is_public
  cidr_block        = lookup(values(var.compute_and_load_balancer_specs)[count.index], "cidr")
  compartment_id    = var.network_compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "${var.region_key}-${keys(var.compute_and_load_balancer_specs)[count.index]}-${var.subnet}"
  dns_label         = "${var.region_key}${keys(var.compute_and_load_balancer_specs)[count.index]}${var.subnet}"
  security_list_ids = compact([oci_core_security_list.sl[count.index].id, var.deploy_fss ? oci_core_security_list.sl_fss[count.index].id : ""])
  route_table_id    = oci_core_route_table.rt[count.index].id
}
# rt
resource "oci_core_route_table" "rt" {
  count = length(var.compute_and_load_balancer_specs)

  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name = "${var.region_key}-${keys(var.compute_and_load_balancer_specs)[count.index]}-${var.route_table}"
  # route rule for igw (for public subnets)
  dynamic route_rules {
    # if public, then open ingress to public internet
    for_each = var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? [1] : []
    content { 
      network_entity_id = oci_core_internet_gateway.igw.id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }
  # route rule for ngw (for private subnets)
  dynamic route_rules {
    for_each = var.use_ngw && ! var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? [1] : []
    content { 
      network_entity_id = oci_core_nat_gateway.ngw[0].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }
  # route rule for sgw (for private subnets)
  dynamic route_rules {
    for_each = var.use_sgw && ! var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? [1] : []
    content { 
      network_entity_id = oci_core_service_gateway.sgw[0].id
      destination       = data.oci_core_services.available_services.services.0.cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
    }
  }
}
# sl
resource "oci_core_security_list" "sl" {
  count = length(var.compute_and_load_balancer_specs)

  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.region_key}-${keys(var.compute_and_load_balancer_specs)[count.index]}-${var.security_list}"

  # tcp open for ports 22, 80, 443, 3080 and 3306.

  # outbound traffic
  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
  }
  # inbound traffic
  ingress_security_rules {
    protocol = 6
    source   = var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? "0.0.0.0/0" : var.vcn_cidr

    tcp_options {
      # ssh
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? "0.0.0.0/0" : var.vcn_cidr

    tcp_options {
      # http
      max = 80
      min = 80
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? "0.0.0.0/0" : var.vcn_cidr

    tcp_options {
      # https
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? "0.0.0.0/0" : var.vcn_cidr

    tcp_options {
      # information
      max = 3080
      min = 3080
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.compute_and_load_balancer_specs[keys(var.compute_and_load_balancer_specs)[count.index]].is_public ? "0.0.0.0/0" : var.vcn_cidr

    tcp_options {
      # mysql
      max = 3306
      min = 3306
    }
  }
}
# if deploy fss, sl for fss
resource "oci_core_security_list" "sl_fss" {
  count = var.deploy_fss ? length(var.compute_and_load_balancer_specs) : 0

  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.region_key}-${keys(var.compute_and_load_balancer_specs)[count.index]}-${var.security_list}-${var.file_storage_service}"

  # outbound traffic
  egress_security_rules {
    destination      = var.vcn_cidr
    protocol         = "all"
  }
  # inbound traffic
  ingress_security_rules {
    protocol = 6
    source   = var.vcn_cidr

    tcp_options {
      max = 111
      min = 111
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.vcn_cidr

    tcp_options {
      max = 2050
      min = 2048
    }
  }
  ingress_security_rules {
    protocol = 17
    source   = var.vcn_cidr

    udp_options {
      max = 111
      min = 111
    }
  }
  ingress_security_rules {
    protocol = 17
    source   = var.vcn_cidr

    udp_options {
      max = 2048
      min = 2048
    }
  }
}