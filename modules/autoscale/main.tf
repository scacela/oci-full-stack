# resources:
# autoscaling configuration

# autoscaling configuration
resource "oci_autoscaling_auto_scaling_configuration" "autoscaling_configuration" {
    count = length(var.computes_pool_specs)

    auto_scaling_resources {
        # resource depends on compute module
        id = var.instance_pool_ocids[count.index]
        type = "instancePool"
    }
    compartment_id = var.autoscaling_compartment_ocid
    policies {
        policy_type = var.autoscaling_policy_type
        capacity {
            initial = var.autoscaling_node_count_initial # initial number of instances
            max     = var.autoscaling_node_count_max # max number of instances to scale out to
            min     = var.autoscaling_node_count_min # min number of instances to scale in to
        }
        display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}-${var.autoscaling_configuration}-policy"
        is_enabled = true
        rules {
            action {
                type = var.scale_in_action_type # e.g. "CHANGE_COUNT_BY"
                value = var.scale_in_action_value # e.g. -1
            }
            display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}-${var.autoscaling_configuration}-rule-scale-in"
            metric {
                metric_type = var.scale_in_metric_type # e.g. "CPU_UTILIZATION"
                threshold {
                  operator = var.scale_in_threshold_operator # e.g. "LT"
                  value    = var.scale_in_threshold_value # e.g. 10
                }
            }
        }
        rules {
            action {
                type = var.scale_out_action_type # e.g. "CHANGE_COUNT_BY"
                value = var.scale_out_action_value # e.g. 1
            }
            display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}-${var.autoscaling_configuration}-rule-scale-out"
            metric {
                metric_type = var.scale_out_metric_type # e.g. "CPU_UTILIZATION"
                threshold {
                  operator = var.scale_out_threshold_operator # e.g. "GT"
                  value    = var.scale_out_threshold_value # e.g. 50
                }
            }
        }
    }
    display_name = "${var.region_key}-${keys(var.computes_pool_specs)[count.index]}-${var.compute_instance}-${var.autoscaling_configuration}"
}