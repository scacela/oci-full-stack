data "template_file" "bootstrap_fss" {
  count = var.deploy_fss && var.enable_is_bootstrapped_fss ? 1 : 0
  template = file("${path.module}/user_data/bootstrap-fss.tpl")
  vars = {
    fss_export_path = var.fss_export_path
    mount_target_private_ip = var.mount_target_private_ip
  }
}
data "template_file" "bootstrap_http_server" {
  count = var.enable_is_bootstrapped_http_server ? 1 : 0
  template = file("${path.module}/user_data/bootstrap-http-server.tpl")
  vars = {
    http_app_tar_file_url = var.http_app_tar_file_url
  }
}
data "template_file" "bootstrap_ssh_key" {
  count = var.enable_is_bootstrapped_ssh_key ? 1 : 0
  template = file("${path.module}/user_data/bootstrap-ssh-key.tpl")
  vars = {
    tf_generated_ssh_key = var.tf_generated_ssh_key
  }
}

data "template_file" "bootstrap_vnc_server" {
  count = var.enable_is_bootstrapped_vnc_server ? 1 : 0
  template = file("${path.module}/user_data/bootstrap-vnc-server.tpl")
  vars = {
    vncpasswd = var.vncpasswd
  }
}
# bootstrapping for instance configurations for pool nodes
data "template_cloudinit_config" "bootstrap_pool" {
  count = length(var.computes_pool_specs)

  gzip          = false
  base64_encode = false
  # fss
  dynamic part {
    for_each = var.deploy_fss && var.enable_is_bootstrapped_fss && values(var.computes_pool_specs)[count.index].is_bootstrapped_fss ? [1] : []
    content {
    filename = "bootstrap-fss"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_fss[0].rendered
    }
  }
  # http-server
  dynamic part {
    for_each = var.deploy_load_balancer && var.enable_is_bootstrapped_http_server && values(var.computes_pool_specs)[count.index].is_bootstrapped_http_server ? [1] : []
    content {
    filename = "bootstrap-http-server"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_http_server[0].rendered
    }
  }
  # ssh-key
 dynamic part {
    for_each = var.enable_is_bootstrapped_ssh_key && values(var.computes_pool_specs)[count.index].is_bootstrapped_ssh_key ? [1] : []
    content {
    filename = "bootstrap-ssh-key"
    content_type = "text/x-shellscript"
    content = data.template_file.bootstrap_ssh_key[0].rendered
    }
  }
  # vnc-server
  dynamic part {
    for_each = var.enable_is_bootstrapped_vnc_server && values(var.computes_pool_specs)[count.index].is_bootstrapped_vnc_server ? [1] : []
    content {
    filename = "bootstrap-vnc-server"
    content_type = "text/x-shellscript"
    content = data.template_file.bootstrap_vnc_server[0].rendered
    }
  }
}
# bootstrapping for solo nodes
data "template_cloudinit_config" "bootstrap_solo" {
  count = length(var.computes_solo_specs)

  gzip          = false
  base64_encode = false
  # fss
  dynamic part {
    for_each = var.deploy_fss && var.enable_is_bootstrapped_fss && values(var.computes_solo_specs)[count.index].is_bootstrapped_fss ? [1] : []
    content {
    filename = "bootstrap-fss"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_fss[0].rendered
    }
  }
  # http-server
  dynamic part {
    for_each = var.deploy_load_balancer && var.enable_is_bootstrapped_http_server && values(var.computes_solo_specs)[count.index].is_bootstrapped_http_server ? [1] : []
    content {
    filename = "bootstrap-http-server"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_http_server[0].rendered
    }
  }
  # ssh-key
 dynamic part {
    for_each = var.enable_is_bootstrapped_ssh_key && values(var.computes_solo_specs)[count.index].is_bootstrapped_ssh_key ? [1] : []
    content {
    filename = "bootstrap-ssh-key"
    content_type = "text/x-shellscript"
    content = data.template_file.bootstrap_ssh_key[0].rendered
    }
  }
  # vnc-server
  dynamic part {
    for_each = var.enable_is_bootstrapped_vnc_server && values(var.computes_solo_specs)[count.index].is_bootstrapped_vnc_server ? [1] : []
    content {
    filename = "bootstrap-vnc-server"
    content_type = "text/x-shellscript"
    content = data.template_file.bootstrap_vnc_server[0].rendered
    }
  }
}