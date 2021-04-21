# resources:
# instance configuration, instance pool

# instance configuration
resource "oci_core_instance_configuration" "ic" {
    count = length(var.compute_specs)
    
    compartment_id = var.compute_compartment_ocid
    display_name = "${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.instance_configuration}"
    instance_details {
        instance_type = "compute"
        launch_details {
            metadata = {
                ssh_authorized_keys = "${var.instance_configuration_ssh_public_key}\n${var.tf_generated_ssh_key_pub}"
                user_data           = var.deploy_fss ? base64encode(data.template_file.configure_fss.rendered) : null
            }
            availability_domain = var.ad_name
            compartment_id = var.compute_compartment_ocid
            create_vnic_details {
                assign_public_ip = var.compute_specs[keys(var.compute_specs)[count.index]].is_public
                display_name = "${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.compute_instance}"
                hostname_label = "${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.compute_instance}"
                subnet_id = var.subnet_displaynames_and_ocids["${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.subnet}"]
            }
            display_name = "${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.compute_instance}"
            fault_domain = var.fd_names[count.index%length(var.fd_names)]
            shape = var.instance_configuration_shape
            dynamic shape_config {
                for_each = var.instance_configuration_shape == "VM.Standard.E3.Flex" || var.instance_configuration_shape == "VM.Standard.E4.Flex" ? [1] : []
                content {
                memory_in_gbs = var.instance_configuration_shape_config_memory_in_gbs
                ocpus = var.instance_configuration_shape_config_ocpus
                }
            }
            source_details {
                source_type = "image"
                image_id = var.image_ocid
            }
        }
    }
}

# instance pool
resource "oci_core_instance_pool" "pool" {
    count = length(var.compute_specs)

    compartment_id = var.compute_compartment_ocid
    # resource depends on ic
    instance_configuration_id = oci_core_instance_configuration.ic[count.index].id
    placement_configurations {
        availability_domain = var.ad_name
        primary_subnet_id = var.subnet_displaynames_and_ocids["${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.subnet}"]
        fault_domains = var.fd_names
    }
    size = var.instance_pool_node_count_initial
    display_name = "${var.region_key}-${keys(var.compute_specs)[count.index]}-${var.instance_pool}"
    dynamic load_balancers {
        # load_balancer attribute depends on load-balancer module
      for_each = var.deploy_load_balancer && contains(var.compute_load_balanced, keys(var.compute_specs)[count.index]) ? [1] : []
      content {
        backend_set_name = "${var.region_key}-${var.compute_load_balanced_and_load_balancer[keys(var.compute_specs)[count.index]]}-${var.load_balancer_backend_set}"
        load_balancer_id = var.lb_displaynames_and_ocids["${var.region_key}-${var.compute_load_balanced_and_load_balancer[keys(var.compute_specs)[count.index]]}-${var.load_balancer}"]
        port = var.backend_port
        vnic_selection = "PrimaryVnic"
      }
    }
}