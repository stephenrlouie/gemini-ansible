echo -n "  - " >> /var/www/html/coreos/pxe-cloud-config.yml
cat ansible.rsa.pub >> /var/www/html/coreos/pxe-cloud-config.yml
cp ansible.rsa.pub /vagrant
mv ansible.rsa* .ssh/
