yum install -y tftp-server
cp -r /vagrant/provision_files/tftpboot /
cp /vagrant/provision_files/tftp /etc/xinetd.d/tftp

sudo service xinetd restart