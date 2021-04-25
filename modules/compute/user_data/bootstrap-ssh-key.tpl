#!bin/bash

# set up log folder
mkdir -p /home/opc/bootstrap-logs
# set up log file
sudo touch /home/opc/bootstrap-logs/ssh-key.log
# set ownership of log folder
chown -R opc:opc /home/opc/bootstrap-logs
# set mode of log folder
chmod -R 755 /home/opc/bootstrap-logs

echo 'set up generated ssh key' >> /home/opc/bootstrap-logs/ssh-key.log
cat <<EOT >> /home/opc/.ssh/id_rsa
${tf_generated_ssh_key}
EOT