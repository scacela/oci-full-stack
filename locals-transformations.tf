# compute specs, bastion specs
locals {
  # deploy bastion?
  deploy_bastion = var.deploy_compute && var.deploy_bastion ? true : false
  # merge compute_collective_specs with bastion_specs if deploy bastion
  compute_collective_specs = var.deploy_bastion ? merge(local.compute_specs, local.bastion_specs) : toset(local.compute_specs)
}
# infrastructure entities that will each be deployed as part of an instance pool
locals {
  # helper
  computes_pool_helper = [
    for i in keys(local.compute_collective_specs) :
    local.compute_collective_specs[i].is_pool ? i : ""
  ]
  # names
  computes_pool = compact(local.computes_pool_helper)
  # keys: names of computes that will be part of an instance pool
  # values: their specifications
  computes_pool_specs = {
    for i in local.computes_pool :
    i => local.compute_collective_specs[i]
  }
}
# infrastructure entities that will each be deployed as solo compute instances
locals {
  # helper
  computes_solo_helper = [
    for i in keys(local.compute_collective_specs) :
    ! local.compute_collective_specs[i].is_pool ? i : ""
  ]
  # names
  computes_solo = compact(local.computes_solo_helper)
  # keys: names of computes that will be deployed as solo compute instances
  # values: their specifications
  computes_solo_specs = {
    for i in local.computes_solo :
    i => local.compute_collective_specs[i]
  }
}
# load balanced and load balancers
locals {
  # helper
  computes_load_balanced_helper = [
    for i in keys(local.compute_collective_specs) :
    local.compute_collective_specs[i].load_balancer != null ? i : ""
  ]
  # names of load-balanced computes
  computes_load_balanced = compact(local.computes_load_balanced_helper)
  # names of load balancers, each generated from the name of its associated compute group
  load_balancers = [
    for i in local.computes_load_balanced :
    "${local.load_balancer}${i}"
  ]
  # keys: names of load-balanced computes
  # values: names of their load balancers
  computes_load_balanced_and_load_balancer = zipmap(local.computes_load_balanced, local.load_balancers)
  # helper
  load_balancer_specs_helper = { for i in keys(local.compute_collective_specs) :
  i => local.compute_collective_specs[i] if local.compute_collective_specs[i].load_balancer != null }
  # keys: names of load balancers
  # values: their specifications
  load_balancer_specs = {
    for i, j in local.computes_load_balanced_and_load_balancer :
    j => local.load_balancer_specs_helper[i].load_balancer
  }
}
# compute specs, bastion specs, load balancer specs
locals {
  # keys: names of computes, names of load balancers
  # values: their specifications
  compute_and_load_balancer_specs = merge(local.compute_collective_specs, local.load_balancer_specs)
}
# other transformations
locals {
  # image ocids: first element for latest image
  image_ocid = data.oci_core_images.compute_images.images[0].id
  bastion_image_ocid = data.oci_core_images.bastion_images.images[0].id
  # ad number: use first availability domain if user-input value for ad number is out of range given the region.
  ad_number = var.ad_number <= length(data.oci_identity_availability_domains.compute_ads.availability_domains) ? var.ad_number : 1
}