locals {
  # keys: names of computes
  # values: their specifications
  compute_specs = {
    web = { 
      is_public =  false
      cidr = var.subnet_cidr_web
      load_balancer = { 
        is_public =  true
        cidr = var.subnet_cidr_lbweb
        }
      is_pool = true
      image_ocid = local.image_ocid
      shape = var.compute_shape
      shape_config_memory_in_gbs = var.compute_shape_config_memory_in_gbs
      shape_config_ocpus = var.compute_shape_config_ocpus
      is_bootstrapped_fss = true
      is_bootstrapped_http_server = true
      is_bootstrapped_ssh_key = true
      is_bootstrapped_vnc_server = true
      }
    app = { 
      is_public =  false
      cidr = var.subnet_cidr_app
      load_balancer = { 
        is_public =  false
        cidr = var.subnet_cidr_lbapp
        }
      is_pool = true
      image_ocid = local.image_ocid
      shape = var.compute_shape
      shape_config_memory_in_gbs = var.compute_shape_config_memory_in_gbs
      shape_config_ocpus = var.compute_shape_config_ocpus
      is_bootstrapped_fss = true
      is_bootstrapped_http_server = true
      is_bootstrapped_ssh_key = true
      is_bootstrapped_vnc_server = true
      }
    db = { 
      is_public =  false
      cidr = var.subnet_cidr_db
      load_balancer = null
      is_pool = true
      image_ocid = local.image_ocid
      shape = var.compute_shape
      shape_config_memory_in_gbs = var.compute_shape_config_memory_in_gbs
      shape_config_ocpus = var.compute_shape_config_ocpus
      is_bootstrapped_fss = true
      is_bootstrapped_http_server = true
      is_bootstrapped_ssh_key = true
      is_bootstrapped_vnc_server = true
      }
  }
  # keys: names of bastion computes
  # values: their specifications
  bastion_specs = {
    bastion = { 
      is_public =  true
      cidr = var.subnet_cidr_bastion
      load_balancer = null
      is_pool = false
      image_ocid = local.bastion_image_ocid
      shape = var.compute_shape
      shape_config_memory_in_gbs = var.bastion_shape_config_memory_in_gbs
      shape_config_ocpus = var.bastion_shape_config_ocpus
      is_bootstrapped_fss = true
      is_bootstrapped_http_server = true
      is_bootstrapped_ssh_key = true
      is_bootstrapped_vnc_server = true
      }
  }
}