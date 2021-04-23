#!bin/bash

# set up log folder
mkdir -p /home/opc/bootstrap-logs

echo 'set up ssh key' >> /home/opc/bootstrap-logs/ssh-key.log

cat <<EOT >> /home/opc/.ssh/id_rsa
${tf_generated_ssh_key}
EOT