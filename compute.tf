# compute instance
resource "oci_core_instance" "compute" {
    count = (var.deploy_compute ? 1 : 0) * length(keys(local.infra_entities_is_public))
    # availability_domain = lookup(data.oci_identity_availability_domains.compute_ads.availability_domains[count.index],"name")
    availability_domain = lookup(data.oci_identity_availability_domains.compute_ads.availability_domains[local.ad_number - 1],"name")
    compartment_id = var.compute_compartment_ocid
    shape = var.compute_shape
    display_name = "${local.region}-${keys(local.infra_entities_is_public)[count.index]}-${local.compute_instance}"
    create_vnic_details {
        assign_public_ip = values(local.infra_entities_is_public)[count.index]
        display_name = "${local.region}-${keys(local.infra_entities_is_public)[count.index]}-${local.compute_instance}-vnic"
        hostname_label = "${local.region}-${keys(local.infra_entities_is_public)[count.index]}-${local.compute_instance}"
        subnet_id = oci_core_subnet.sub[count.index].id
    }
    fault_domain = "FAULT-DOMAIN-${(count.index%3)+1}"
    metadata = {
        ssh_authorized_keys = tls_private_key.ssh.public_key_openssh
    }
    source_details {
        source_id = var.image[var.region]
        source_type = "image"
    }
    preserve_boot_volume = false
}

# ssh private key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}