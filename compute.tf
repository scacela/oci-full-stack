# # compute instance
# resource "oci_core_instance" "compute" {
#     count = (var.deploy_compute ? 1 : 0) * length(keys(local.infra_entities_specs))
#     availability_domain = local.ad_name
#     compartment_id = var.compute_compartment_ocid
#     shape = var.compute_shape
#     display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}"
#     create_vnic_details {
#         assign_public_ip = local.infra_entities_specs[keys(local.infra_entities_specs)[count.index]].is_public
#         display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}-vnic"
#         hostname_label = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}"
#         subnet_id = oci_core_subnet.sub[count.index].id
#     }
#     # fault_domain = "FAULT-DOMAIN-${(count.index%3)+1}"
#     fault_domain = "FAULT-DOMAIN-1"
#     metadata = {
#         ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.ssh.public_key_openssh}"
#     }
#     source_details {
#         source_id = var.image[var.region]
#         source_type = "image"
#     }
#     preserve_boot_volume = false
# }

# ssh private key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# instance configuration
resource "oci_core_instance_configuration" "ic" {
    count = (var.deploy_compute ? 1 : 0) * length(local.infra_entities_specs)
    
    compartment_id = var.compute_compartment_ocid
    instance_details {
        instance_type = "compute"
        block_volumes {
            attach_details {
                type = "iscsi"
                display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.block_volume}-${local.block_volume}"
                is_pv_encryption_in_transit_enabled = true
                is_read_only = false
                is_shareable = true
                use_chap = false
            }
            create_details {
                availability_domain = local.ad_name
                compartment_id = var.compute_compartment_ocid
                display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.block_volume}"
                size_in_gbs = var.block_volume_size_GiB
                vpus_per_gb = 10
            }
        }
        launch_details {
            metadata = {
                ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.ssh.public_key_openssh}"
            }
            availability_domain = local.ad_name
            compartment_id = var.compute_compartment_ocid
            create_vnic_details {
                assign_public_ip = local.infra_entities_specs[keys(local.infra_entities_specs)[count.index]].is_public
                display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}"
                hostname_label = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}"
                subnet_id = oci_core_subnet.sub[count.index].id
            }
            display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}"
            fault_domain = "FAULT-DOMAIN-1"
            is_pv_encryption_in_transit_enabled = true
            launch_options {
                boot_volume_type = "iscsi"
                is_pv_encryption_in_transit_enabled = true
                network_type = "paravirtualized"
                remote_data_volume_type = "iscsi"
            }
            shape = var.compute_shape
            dynamic shape_config {
                for_each = var.compute_shape == "VM.Standard.E3.Flex" || var.compute_shape == "VM.Standard.E4.Flex" ? [1] : []
                content {
                #Optional
                memory_in_gbs = var.compute_shape_config_memory_in_gbs
                ocpus = var.compute_shape_config_ocpus
                }
            }
            source_details {
                source_type = "image"
                image_id = var.image[var.region]
            }
        }
    }
}

# instance pool
resource "oci_core_instance_pool" "pool" {
    count = (var.deploy_compute ? 1 : 0) * length(keys(local.infra_entities_specs))

    compartment_id = var.compute_compartment_ocid
    instance_configuration_id = oci_core_instance_configuration.ic[count.index].id
    placement_configurations {
        availability_domain = local.ad_name
        primary_subnet_id = oci_core_subnet.sub[count.index].id
        fault_domains = ["FAULT-DOMAIN-1"]
    }
    size = var.compute_initial_pool_size
    display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}-${local.instance_pool}"
    dynamic load_balancers {
      for_each = contains(local.load_balanced_infra_entities_pruned, keys(local.infra_entities_specs)[count.index]) ? [1] : []
      content {
        backend_set_name = "${local.region}-${local.infra_entities_loadbalanced_and_loadbalancing[keys(local.infra_entities_specs)[count.index]]}-${local.load_balancer_backend_set}"
        load_balancer_id = local.lb_displaynames_and_ocids["${local.region}-${local.infra_entities_loadbalanced_and_loadbalancing[keys(local.infra_entities_specs)[count.index]]}"]
        port = var.backend_port
        vnic_selection = "PrimaryVnic"
      }
    }
}

resource "oci_load_balancer_load_balancer" "lb" {
  count = (var.deploy_compute ? 1 : 0) * length(local.load_balancing_infra_entities_specs)

  display_name = "${local.region}-${keys(local.load_balancing_infra_entities_specs)[count.index]}"
  compartment_id = var.compute_compartment_ocid
  shape          = var.load_balancer_shape
  subnet_ids = [local.subnet_displaynames_and_ocids["${local.region}-${keys(local.load_balancing_infra_entities_specs)[count.index]}-${local.subnet}"]]
}

resource "oci_load_balancer_backend_set" "lb_backend_set" {
  count = (var.deploy_compute ? 1 : 0) * length(local.load_balancing_infra_entities_specs)

  health_checker {
    protocol = var.backend_set_health_checker_protocol
    url_path = var.lb_health_check_url_path
  }

  load_balancer_id = oci_load_balancer_load_balancer.lb[count.index].id
  name             = "${local.region}-${keys(local.load_balancing_infra_entities_specs)[count.index]}-${local.load_balancer_backend_set}"
  policy           = var.backend_set_policy
}

locals {
# helpers
lb_displaynames_and_ocids = {
    for i in oci_load_balancer_load_balancer.lb :
    i.display_name => i.id
  }
subnet_displaynames_and_ocids = {
    for i in oci_core_subnet.sub :
    i.display_name => i.id
  }
}

resource "oci_autoscaling_auto_scaling_configuration" "autoscaling_configuration" {
    count = (var.deploy_compute ? 1 : 0) * length(local.infra_entities_specs)

    auto_scaling_resources {
        id = oci_core_instance_pool.pool[count.index].id
        type = "instancePool"
    }
    compartment_id = var.compute_compartment_ocid
    policies {
        policy_type = var.autoscaling_policy_type
        capacity {
            initial = var.autoscaling_node_count_initial # initial number of instances
            max     = var.autoscaling_node_count_max # max number of instances to scale out to
            min     = var.autoscaling_node_count_min # min number of instances to scale in to
        }
        display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}-${local.autoscaling_configuration}-policy"
        is_enabled = true
        # resource_action {
        #   action_type = "power"
        #   action    = "STOP"
        # }
        rules {
            action {
                type = "CHANGE_COUNT_BY"
                value = -1
            }
            display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}-${local.autoscaling_configuration}-rule"
            metric {
                metric_type = "CPU_UTILIZATION"
                threshold {
                  operator = "LT"
                  value    = 1
                }
            }
        }
    }
    cool_down_in_seconds = 300 # default as well as minumum value
    display_name = "${local.region}-${keys(local.infra_entities_specs)[count.index]}-${local.compute_instance}-${local.autoscaling_configuration}"
    is_enabled = true
}