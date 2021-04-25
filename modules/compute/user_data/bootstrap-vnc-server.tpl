#!bin/bash

# set up log folder
mkdir -p /home/opc/bootstrap-logs
# set up log file
sudo touch /home/opc/bootstrap-logs/vnc-server.log
# set ownership of log folder
chown -R opc:opc /home/opc/bootstrap-logs
# set mode of log folder
chmod -R 755 /home/opc/bootstrap-logs

echo 'install Server with GUI' >> /home/opc/bootstrap-logs/vnc-server.log
sudo yum -y groupinstall 'Server with GUI' 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'install tigervnc-server, mesa-libGL' >> /home/opc/bootstrap-logs/vnc-server.log
sudo yum -y install tigervnc-server mesa-libGL 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'sudo systemctl set-default graphical.target' >> /home/opc/bootstrap-logs/vnc-server.log
sudo systemctl set-default graphical.target 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service' >> /home/opc/bootstrap-logs/vnc-server.log
sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'replace <USER> with opc in /etc/systemd/system/vncserver@:1.service' >> /home/opc/bootstrap-logs/vnc-server.log
sudo sed -i 's/<USER>/opc/g' /etc/systemd/system/vncserver@:1.service 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'make /home/opc/.vnc' >> /home/opc/bootstrap-logs/vnc-server.log
sudo mkdir -p /home/opc/.vnc/ 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'set ownership of /home/opc/.vnc to opc' >> /home/opc/bootstrap-logs/vnc-server.log
sudo chown opc:opc /home/opc/.vnc 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'set password for VNC Server' >> /home/opc/bootstrap-logs/vnc-server.log
echo ${vncpasswd} | vncpasswd -f > /home/opc/.vnc/passwd

echo 'set ownership of VNC Server password file' >> /home/opc/bootstrap-logs/vnc-server.log
chown opc:opc /home/opc/.vnc/passwd 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'set permissions of VNC Server password file' >> /home/opc/bootstrap-logs/vnc-server.log
chmod 600 /home/opc/.vnc/passwd 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'start VNC Server with systemctl' >> /home/opc/bootstrap-logs/vnc-server.log
sudo systemctl start vncserver@:1.service 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log

echo 'enable VNC Server with systemctl' >> /home/opc/bootstrap-logs/vnc-server.log
sudo systemctl enable vncserver@:1.service 2>&1 >> /home/opc/bootstrap-logs/vnc-server.log