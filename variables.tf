variable "region" {}
# network
variable "network_compartment_ocid" {}
variable "vcn_cidr" { default = "10.0.0.0/16" }
variable "subnet_lb_web_cidr" { default = "10.0.0.0/24" }
variable "subnet_web_cidr" { default = "10.0.1.0/24" }
variable "subnet_lb_app_cidr" { default = "10.2.0.0/24" }
variable "subnet_app_cidr" { default = "10.0.3.0/24" }
variable "subnet_db_cidr" { default = "10.0.4.0/24" }
variable "use_ngw" { default = true }
variable "use_sgw" { default = true }
# compute
variable "deploy_compute" { default = true }
variable "compute_compartment_ocid" {}
variable "compute_shape" { default = "VM.Standard2.1" }
# shorthand values
locals {
  region = lower(data.oci_identity_regions.available_regions.regions.0.key)
  private = "priv"
  public = "pub"
  infra_entities_is_public = {
    # NAME = IS_PUBLIC?
    lbweb = true
    web = false
    lbapp = false
    app = false
    db = false
  }
  infra_entities_cidrs = {
    # NAME = CIDR_RANGE
    lbweb = var.subnet_lb_web_cidr
    web = var.subnet_web_cidr
    lbapp = var.subnet_lb_app_cidr
    app = var.subnet_app_cidr
    db = var.subnet_db_cidr
  }
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
  ad_number = 1
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