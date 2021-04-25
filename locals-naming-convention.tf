# naming convention
locals {
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
}