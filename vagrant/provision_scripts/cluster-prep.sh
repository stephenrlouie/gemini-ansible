cd ~/contrib/ansible/

cp inventory.example.single_master inventory

sed -i 's/#ansible_ssh_user: root/ansible_ssh_user: core/' group_vars/all.yml
sed -i 's/#ansible_python_interpreter/ansible_python_interpreter/' group_vars/all.yml

export GEMINI_MASTER_IP=10.10.10.10

cat >> group_vars/all.yml << EOF
# The URL to download Kubernetes binaries for CoreOS
kube_download_url_base: "http://${GEMINI_MASTER_IP}/releases/kubernetes/v{{ kube_version }}"

# The URL to download Flannel binaries tar file for CoreOS
flannel_download_url_base: "http://${GEMINI_MASTER_IP}/releases/flannel/v{{ flannel_version }}"

# The URL to download Pypy binaries tar file for CoreOS
pypy_download_url_base: "http://${GEMINI_MASTER_IP}/releases/pypy/v{{ pypy_version }}"

EOF

cat >> group_vars/all.yml << EOF
#The adapter to use for flannel
flannel_opts: "--iface=eth1"

#The adapter to use for etcd
etcd_interface: "eth1"

EOF
