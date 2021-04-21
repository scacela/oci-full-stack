# resources:
# file system, mount target, subnet, sl, export

# file system
resource "oci_file_storage_file_system" "file_system" {
  availability_domain = var.ad_name
  compartment_id      = var.fss_compartment_ocid
  display_name = "${var.region_key}-${var.file_storage_service}-${var.filesystem}"
}
# mount target
resource "oci_file_storage_mount_target" "mount_target" {
  availability_domain = var.ad_name
  compartment_id      = var.fss_compartment_ocid
  subnet_id           = oci_core_subnet.sub.id
  display_name   = "${var.region_key}-${var.file_storage_service}-${var.mount_target}"
  hostname_label = "${var.region_key}-${var.file_storage_service}-${var.mount_target}"
}
# subnet for mount target
resource "oci_core_subnet" "sub" {
  prohibit_public_ip_on_vnic = true
  cidr_block        = var.subnet_cidr_fss
  compartment_id    = var.fss_compartment_ocid
  vcn_id            = var.vcn_ocid
  display_name      = "${var.region_key}-${var.file_storage_service}-${var.subnet}"
  dns_label         = "${var.region_key}${var.file_storage_service}${var.subnet}"
  security_list_ids = [oci_core_security_list.sl.id]
}
# sl
resource "oci_core_security_list" "sl" {
  compartment_id = var.fss_compartment_ocid
  vcn_id         = var.vcn_ocid
  display_name   = "${var.region_key}-${var.file_storage_service}-${var.security_list}"

  # Stateful ingress from ALL ports in the source instance CIDR block to TCP ports 111, 2048, 2049, and 2050.
  # Stateful ingress from ALL ports in the source instance CIDR block to UDP ports 111 and 2048.
  # Stateful egress from TCP ports 111, 2048, 2049, and 2050 to ALL ports in the destination instance CIDR block.
  # Stateful egress from UDP port 111 ALL ports in the destination instance CIDR block.

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
# export
resource "oci_file_storage_export" "export" {
  export_set_id = oci_file_storage_mount_target.mount_target.export_set_id
  file_system_id = oci_file_storage_file_system.file_system.id
  path           = var.fss_export_path
  export_options {
    source = "0.0.0.0/0"
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}