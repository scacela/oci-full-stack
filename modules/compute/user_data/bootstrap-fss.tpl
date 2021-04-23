#!bin/bash

# set up log folder
mkdir -p /home/opc/bootstrap-logs

echo 'update yum' >> /home/opc/bootstrap-logs/fss.log
sudo yum -y update 2>&1 >> /home/opc/bootstrap-logs/fss.log

echo 'make local mount folder' >> /home/opc/bootstrap-logs/fss.log
mkdir -p /mnt${fss_export_path} 2>&1 >> /home/opc/bootstrap-logs/fss.log

echo 'install nfs-utils' >> /home/opc/bootstrap-logs/fss.log
sudo yum -y install nfs-utils 2>&1 >> /home/opc/bootstrap-logs/fss.log

echo 'mount the filesystem' >> /home/opc/bootstrap-logs/fss.log
sudo mount ${mount_target_private_ip}:${fss_export_path} /mnt${fss_export_path} 2>&1 >> /home/opc/bootstrap-logs/fss.log

echo 'add mount instructions to /etc/fstab' >> /home/opc/bootstrap-logs/fss.log
sudo echo '${mount_target_private_ip}:${fss_export_path} /mnt${fss_export_path} nfs defaults,nofail,nosuid,resvport 0 0' >> /etc/fstab 2>&1 >> /home/opc/bootstrap-logs/fss.log