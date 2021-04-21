data "template_file" "configure_fss" {
  count = var.deploy_fss ? 1 : 0
  template = <<YAML
  #cloud-config
  runcmd:
  - echo 'Configuring FSS.' >> /home/opc/configure_fss.log
  - sudo yum -y update 2>&1 >> /home/opc/configure_fss.log
  - sudo mkdir -p /mnt${var.fss_export_path}
  - sudo yum -y install nfs-utils 2>&1 >> /home/opc/configure_fss.log
  - sudo mount ${var.mount_target_private_ip}:${var.fss_export_path} /mnt${var.fss_export_path}
  - df -H 2>&1 >> /home/opc/configure_fss.log
  - sudo echo '${var.mount_target_private_ip}:${var.fss_export_path} /mnt${var.fss_export_path} nfs defaults,nofail,nosuid,resvport 0 0' >> /etc/fstab
  YAML
}