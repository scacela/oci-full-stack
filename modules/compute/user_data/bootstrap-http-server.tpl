#!bin/bash

# set up log folder
mkdir -p /home/opc/bootstrap-logs
# set up log file
sudo touch /home/opc/bootstrap-logs/http-server.log
# set ownership of log folder
chown -R opc:opc /home/opc/bootstrap-logs
# set mode of log folder
chmod -R 755 /home/opc/bootstrap-logs

echo 'install HTTP Server' >> /home/opc/bootstrap-logs/http-server.log
sudo yum -y install httpd 2>&1 >> /home/opc/bootstrap-logs/http-server.log

echo 'download the HTTP app content to /var/www/html' >> /home/opc/bootstrap-logs/http-server.log
sudo wget ${http_app_tar_file_url} -P /var/www/html
sudo tar -xf /var/www/html/files.tar -C /var/www/html/

echo 'prepend string with hostname to /var/www/html/index.html' >> /home/opc/bootstrap-logs/http-server.log
if [ -s /var/www/html/index.html ]; then sudo sed -i "1s/^/This is an app running on $(hostname)./" /var/www/html/index.html; else echo "This is an app running on $(hostname)." >> /var/www/html/index.html; fi 2>&1 >> /home/opc/bootstrap-logs/http-server.log

echo 'stop firewalld service' >> /home/opc/bootstrap-logs/http-server/bootstrap.log
sudo service firewalld stop 2>&1 >> /home/opc/bootstrap-logs/http-server.log

echo 'start httpd service' >> /home/opc/bootstrap-logs/http-server/bootstrap.log
sudo service httpd start 2>&1 >> /home/opc/bootstrap-logs/http-server.log