yum install -y dhcp

cp /vagrant/provision_files/dhcpd /etc/sysconfig
cp /vagrant/provision_files/dhcpd.conf /etc/dhcp

sudo service dhcpd restart
