kube_version=1.1.4
flannel_version=0.5.5

./get_cent6_minimal.sh
./get_coreos_pxe.sh

kube_version=$kube_version ./get_kube.sh
flannel_version=$flannel_version ./get_flannel.sh
