sudo systemctl enable docker.service
sudo groupadd docker
sudo gpasswd -a vagrant docker
sudo systemctl restart docker.service
