# common
variable "region" {}
variable "ad_number" { default = 1 }
# network
variable "network_compartment_ocid" {}
variable "vcn_cidr" { default = "10.0.0.0/16" }
variable "subnet_lb_web_cidr" { default = "10.0.0.0/24" }
variable "subnet_web_cidr" { default = "10.0.1.0/24" }
variable "subnet_lb_app_cidr" { default = "10.0.2.0/24" }
variable "subnet_app_cidr" { default = "10.0.3.0/24" }
variable "subnet_db_cidr" { default = "10.0.4.0/24" }
variable "use_ngw" { default = true }
variable "use_sgw" { default = true }
# compute
variable "deploy_compute" { default = true }
variable "compute_compartment_ocid" {}
variable "compute_shape" { default = "VM.Standard2.1" }
variable "ssh_public_key" {}
variable "compute_shape_config_memory_in_gbs" { default = 32 }
variable "compute_shape_config_ocpus" { default = 8 }
variable "block_volume_size_GiB" { default = 128 }
variable "compute_initial_pool_size" { default = 1 }
variable "load_balancer_shape" { default = "10Mbps" }
variable "backend_set_health_checker_protocol" { default = "HTTP" }
variable "backend_set_name_prefix" { default = "backendset" }
variable "backend_set_policy" { default = "ROUND_ROBIN" }
variable "backend_port" { default = 80 }
variable "lb_health_check_url_path" { default = "/" }
variable "autoscaling_policy_type" { default = "threshold" }
variable "autoscaling_node_count_initial" { default = 2 }
variable "autoscaling_node_count_max" { default = 4 }
variable "autoscaling_node_count_min" { default = 2 }

locals {
  # specifications for infrastructure entities
  infra_entities_specs = {
    web = { 
      is_public =  false
      cidr = var.subnet_web_cidr
      load_balancer = { 
        is_public =  true
        cidr = var.subnet_lb_web_cidr
        }
      }
    app = { 
      is_public =  false
      cidr = var.subnet_app_cidr
      load_balancer = { 
        is_public =  false
        cidr = var.subnet_lb_app_cidr
        }
      }
    db = { 
      is_public =  false
      cidr = var.subnet_db_cidr
      load_balancer = null
      }
  }

  # list of infrastructure entities that are being load balanced, unpruned
  load_balanced_infra_entities_unpruned = [
      for i in keys(local.infra_entities_specs) :
      local.infra_entities_specs[i].load_balancer != null ? i : ""
    ]
  # pruned list of infrastructure entities that are being load balanced
  load_balanced_infra_entities_pruned = compact(local.load_balanced_infra_entities_unpruned)

  # list of infrastructure entities that are load balancing
  load_balancing_infra_entities = [
      for i in local.load_balanced_infra_entities_pruned :
      "${local.load_balancer}${i}"
    ]

  # mapping between infrastructure entities that are load balancing and their specs
  load_balancing_infra_entities_specs_helper = { for i in keys(local.infra_entities_specs) :
    i => local.infra_entities_specs[i] if local.infra_entities_specs[i].load_balancer != null }
  
  load_balancing_infra_entities_specs = {
    for i, j in local.infra_entities_loadbalanced_and_loadbalancing :
    j => local.load_balancing_infra_entities_specs_helper[i].load_balancer
  }

  # mapping between infrastructure entities that are being load balanced
  # and infrastructure entities that are load balancing
  infra_entities_loadbalanced_and_loadbalancing = zipmap(local.load_balanced_infra_entities_pruned, local.load_balancing_infra_entities)
  
  # mapping between infrastructure entities that are being load balanced or are load balancing, and their respective specs
  infra_entities_compute_and_lb_specs = merge(local.infra_entities_specs, local.load_balancing_infra_entities_specs)
  # common
  region = lower(data.oci_identity_regions.available_regions.regions.0.key)
  private = "priv"
  public = "pub"
  ad_name = lookup(data.oci_identity_availability_domains.compute_ads.availability_domains[var.ad_number - 1],"name")
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
  block_volume = "bv"
  instance_pool = "pool"
  load_balancer = "lb"
  load_balancer_backend_set = "backset"
  autoscaling_configuration = "scaler"
}
# image variables (Oracle-Linux-7.7-2020.02.21-0)
variable "image" {
  type = map(string)
  default = {
    "ap-melbourne-1"  = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaavpiybmiqoxcohpiih2gasjgqpsiyz4ggylyhhitmrmf3j2ycucrq"
    "ap-mumbai-1"     = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaarrsp6bazleeeghz6jcifatswozlqkoffzwxzbt2ilj2f65ngqi6a"
    "ap-osaka-1"      = "ocid1.image.oc1.ap-osaka-1.aaaaaaaafa5rhs2n3dyuncddh5oynk6gisvotvcvch3e6xwplji7phwtbqqa"
    "ap-seoul-1"      = "ocid1.image.oc1.ap-seoul-1.aaaaaaaadrnhec6655uedkshgcklewzikoqcwr65sevbu27z7vzagniihfha"
    "ap-sydney-1"     = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaplq4fjdnoooudaqwgzaidh6r3lp3xdhqulx454jivy33t53hokga"
    "ap-tokyo-1"      = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa5mpgmnwqwacey5gvczawugmo3ldgrjqnleckmnsokrqytcfkzspa"
    "ca-toronto-1"    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaai25l5mqlzvhjzxvb5n4ullqu333bmalyyg3ki53vt24yn6ld7pra"
    "eu-amsterdam-1"  = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaayd4knq4bdh23zqgatgjhoajiz3mx4fy3oy62e5f45ll7trwak5ga"
    "eu-frankfurt-1"  = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4cmgko5la45jui5cuju7byv6dgnfnjbxhwqxaei3q4zjwlliptuq"
    "eu-zurich-1"     = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa4nwf5h6nl3u5cdauemg352itja6izecs7ol73z6jftsg4agpdsma"
    "me-jeddah-1"     = "ocid1.image.oc1.me-jeddah-1.aaaaaaaazrvioeng7va7w4qsuqny4jtxbvnxlf5hu7g2twn6rcwdu35u4riq"
    "sa-saopaulo-1"   = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaalfracz4kuew4yxvgydpnbitip6qsreaz7kpxlkr4p67ravvi4jnq"
    "uk-gov-london-1" = "ocid1.image.oc4.uk-gov-london-1.aaaaaaaaslh4pip7u6iopbpxujy2twi7diqrs6kfvqfhkl27esdadkqa76mq"
    "uk-london-1"     = "ocid1.image.oc1.uk-london-1.aaaaaaaa2uwbd457cd2gtviihmxw7cqfmqcug4ahdg7ivgyzla25pgrn6soa"
    "us-ashburn-1"    = "ocid1.image.oc1.iad.aaaaaaaavzjw65d6pngbghgrujb76r7zgh2s64bdl4afombrdocn4wdfrwdq"
    "us-langley-1"    = "ocid1.image.oc2.us-langley-1.aaaaaaaauckkms7acrl6to3cuhmv6hfjqwlnoxzuzophaose7pi2sfk4dzna"
    "us-luke-1"       = "ocid1.image.oc2.us-luke-1.aaaaaaaadxeycutztmvaeefvilc57lfqool2rlgl2r34juyu4jkbodx2xspq"
    "us-phoenix-1"    = "ocid1.image.oc1.phx.aaaaaaaacy7j7ce45uckgt7nbahtsatih4brlsa2epp5nzgheccamdsea2yq"
    "ap-osaka-1"      = "ocid1.image.oc1.ap-osaka-1.aaaaaaaa23apvyouh3fuiw7aqjo574zsmgdwtetato6uxgu7tct7y4uaqila"
  }
}