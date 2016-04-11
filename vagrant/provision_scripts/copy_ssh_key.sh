echo -n "  - " >> /var/www/html/coreos/pxe-cloud-config.yml
cat id_rsa.pub >> /var/www/html/coreos/pxe-cloud-config.yml
cp id_rsa.pub /vagrant
mv id_rsa* .ssh/
