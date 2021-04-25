# resources:
# instance configuration, instance pool, compute instance

# instance configuration
resource "oci_core_instance_configuration" "ic" {
    count = length(var.computes_pool_specs)
    
    compartment_id = var.compute_compartment_ocid
    display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.instance_configuration}"
    instance_details {
        instance_type = "compute"
        launch_details {
            metadata = {
                ssh_authorized_keys = "${var.ssh_public_key}\n${var.tf_generated_ssh_key_pub}"
                user_data           = base64encode(data.template_cloudinit_config.bootstrap_pool[count.index].rendered)
            }
            availability_domain = var.ad_name
            compartment_id = var.compute_compartment_ocid
            create_vnic_details {
                assign_public_ip = var.computes_pool_specs[keys(var.computes_pool_specs)[count.index]].is_public
                display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}"
                hostname_label = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}"
                subnet_id = var.subnet_display_names_and_ocids["${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.subnet}"]
            }
            display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}"
            fault_domain = var.fd_names[count.index%length(var.fd_names)]
            shape = var.computes_pool_specs[keys(var.computes_pool_specs)[count.index]].shape
            dynamic shape_config {
                for_each = var.compute_shape == "VM.Standard.E3.Flex" || var.compute_shape == "VM.Standard.E4.Flex" ? [1] : []
                content {
                memory_in_gbs = var.computes_pool_specs[keys(var.computes_pool_specs)[count.index]].shape_config_memory_in_gbs
                ocpus = var.computes_pool_specs[keys(var.computes_pool_specs)[count.index]].shape_config_ocpus
                }
            }
            source_details {
                source_type = "image"
                image_id = var.computes_pool_specs[keys(var.computes_pool_specs)[count.index]].image_ocid
            }
        }
    }
}

# instance pool
resource "oci_core_instance_pool" "pool" {
    count = length(var.computes_pool_specs)

    compartment_id = var.compute_compartment_ocid
    # resource depends on ic
    instance_configuration_id = oci_core_instance_configuration.ic[count.index].id
    placement_configurations {
        availability_domain = var.ad_name
        primary_subnet_id = var.subnet_display_names_and_ocids["${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.subnet}"]
        fault_domains = var.fd_names
    }
    size = var.instance_pool_node_count_initial
    display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.instance_pool}"
    dynamic load_balancers {
        # load_balancer attribute depends on load-balancer module
      for_each = var.deploy_load_balancer && contains(var.computes_load_balanced, keys(var.computes_pool_specs)[count.index]) ? [1] : []
      content {
        backend_set_name = "${var.region_key}-${var.computes_load_balanced_and_load_balancer[keys(var.computes_pool_specs)[count.index]]}-${var.load_balancer_backend_set}"
        load_balancer_id = var.lb_display_names_and_ocids["${var.region_key}-${var.computes_load_balanced_and_load_balancer[keys(var.computes_pool_specs)[count.index]]}-${var.load_balancer}"]
        port = var.backend_port
        vnic_selection = "PrimaryVnic"
      }
    }
}

# compute instance
resource "oci_core_instance" "compute" {
    count = length(var.computes_solo_specs)

  availability_domain = var.ad_name
  compartment_id = var.compute_compartment_ocid
  display_name = "${var.region_key}-${keys(var.computes_solo_specs)[count.index]}-${var.compute_instance}"
  shape = var.computes_solo_specs[keys(var.computes_solo_specs)[count.index]].shape
  create_vnic_details {
    subnet_id = var.subnet_display_names_and_ocids["${var.region_key}-${keys(var.computes_solo_specs)[count.index]}-${var.subnet}"]
    assign_public_ip = var.computes_solo_specs[keys(var.computes_solo_specs)[count.index]].is_public
    hostname_label = "${var.region_key}-${keys(var.computes_solo_specs)[count.index]}-${var.compute_instance}"
  }
  source_details {
    source_type = "image"
    source_id   = var.computes_solo_specs[keys(var.computes_solo_specs)[count.index]].image_ocid
  }
  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}\n${var.tf_generated_ssh_key_pub}"
    user_data           = base64encode(data.template_cloudinit_config.bootstrap_solo[count.index].rendered)
  }
}