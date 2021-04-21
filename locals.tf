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
      }
    app = { 
      is_public =  false
      cidr = var.subnet_cidr_app
      load_balancer = { 
        is_public =  false
        cidr = var.subnet_cidr_lbapp
        }
      }
    db = { 
      is_public =  false
      cidr = var.subnet_cidr_db
      load_balancer = null
      }
  }
  
  # helper
  compute_load_balanced_helper = [
      for i in keys(local.compute_specs) :
      local.compute_specs[i].load_balancer != null ? i : ""
    ]
  # names of load-balanced computes
  compute_load_balanced = compact(local.compute_load_balanced_helper)

  # names of load balancers, each generated from the name of its associated compute group
  load_balancers = [
      for i in local.compute_load_balanced :
      "${local.load_balancer}${i}"
    ]

  # keys: names of load-balanced computes
  # values: names of their load balancers
  compute_load_balanced_and_load_balancer = zipmap(local.compute_load_balanced, local.load_balancers)

  # helper
  load_balancer_specs_helper = { for i in keys(local.compute_specs) :
    i => local.compute_specs[i] if local.compute_specs[i].load_balancer != null }

  # keys: names of load balancers
  # values: their specifications
  load_balancer_specs = {
    for i, j in local.compute_load_balanced_and_load_balancer :
    j => local.load_balancer_specs_helper[i].load_balancer
  }

  # keys: names of computes, names of load balancers
  # values: their specifications
  compute_and_load_balancer_specs = merge(local.compute_specs, local.load_balancer_specs)

  # first element for latest image
  image_ocid = data.oci_core_images.compute_images.images[0].id
  bastion_image_ocid = data.oci_core_images.bastion_images.images[0].id

  # deploy bastion?
  deploy_bastion = var.deploy_compute && var.use_bastion ? true : false

  # common
  region_key = lower(data.oci_identity_regions.available_regions.regions.0.key)
  # network
  subnet = "sub"
  route_table = "rt"
  security_list = "sl"
  virtual_cloud_network = "vcn"
  internet_gateway = "igw"
  nat_gateway = "ngw"
  service_gateway = "sgw"
  # compute
  compute_instance = "compute"
    # use first availability domain if user-input value for ad number is out of range given the region.
  ad_number = var.ad_number <= length(data.oci_identity_availability_domains.compute_ads.availability_domains) ? var.ad_number : 1
  ad_name = lookup(data.oci_identity_availability_domains.compute_ads.availability_domains[var.ad_number - 1],"name")
  fd_names = data.oci_identity_fault_domains.compute_fds.fault_domains.*.name
  instance_configuration = "ic"
  instance_pool = "pool"
  # autoscale
  autoscaling_configuration = "autoscaler"
  # load balancer
  load_balancer = "lb"
  load_balancer_backend_set = "backset"
  load_balancer_listener = "listener"
  # file storage
  filesystem = "fs"
  file_storage_service = "fss"
  mount_target = "mt"
  # custom image
  custom_image = "image"
  # bastion
  bastion = "bastion"
}