kube_version=1.2.0

binaries="kube-apiserver 
kube-controller-manager 
kube-proxy 
kube-scheduler 
kubectl 
kubelet"

kube_download_url_base="https://storage.googleapis.com/kubernetes-release/release/v$kube_version/bin/linux/amd64/"

mkdir -p ../provision_files/html/downloads/bins/kubernetes/v$kube_version/

for b in $binaries
do 
  echo $kube_download_url_base$b
  wget $kube_download_url_base$b
  mv $b ../provision_files/html/downloads/bins/kubernetes/v$kube_version/
done
