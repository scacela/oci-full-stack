data "template_file" "bootstrap_fss" {
  count = var.deploy_fss ? 1 : 0
  template = file("${path.module}/user_data/bootstrap-fss.tpl")
  vars = {
    fss_export_path = var.fss_export_path
    mount_target_private_ip = var.mount_target_private_ip
  }
}

data "template_file" "bootstrap_ssh_key" {
  template = file("${path.module}/user_data/bootstrap-ssh-key.tpl")
  vars = {
    tf_generated_ssh_key = var.tf_generated_ssh_key
  }
}

data "template_cloudinit_config" "bootstrap" {
  gzip          = false
  base64_encode = false
  # fss
  dynamic part {
    for_each = var.deploy_fss ? [1] : []
    content {
    filename = "bootstrap-fss"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_fss[0].rendered
    }
  }
  # http-server
  dynamic part {
    for_each = var.deploy_load_balancer ? [1] : []
    content {
    filename = "bootstrap-http-server"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/user_data/bootstrap-http-server")
    }
  }
  # ssh-key
  part {
    filename = "bootstrap-ssh-key"
    content_type = "text/x-shellscript"
    content = data.template_file.bootstrap_ssh_key.rendered
  }
}