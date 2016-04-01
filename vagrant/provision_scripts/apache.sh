yum install -y httpd
cp -r /vagrant/provision_files/html /var/www
sudo service httpd restart