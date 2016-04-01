wget https://github.com/coreos/flannel/releases/download/v$flannel_version/flannel-$flannel_version-linux-amd64.tar.gz 
mkdir -p ../provision_files/html/downloads/bins/flannel/v$flannel_version
mv flannel-$flannel_version-linux-amd64.tar.gz ../provision_files/html/downloads/bins/flannel/v$flannel_version 
