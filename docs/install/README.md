# Gemini Installation Guide

This guide walks through the steps for deploying Gemini to a baremetal
server cluster. At least 2 servers are required to support this deployment
type. One server is used as the Gemini Master and one or more servers are
used to run clustering software, such as [Kubernetes](http://kubernetes.io/).

**Note**: These steps will soon be replaced by a simple installation script.

## Before You Start

Make sure your bare meta servers are "racked and stacked" and connected to
the network.

The server that acts as the Gemini Master needs to be installed with with
CentOS Linux 7. The Gemini team has been using the [CentOS 7 minimal ISO](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso). SSH to the Gemini Master after the CentOS 7 installation is complete and
the server has rebooted.

Install Ansible:
```
# rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
# yum -y install ansible
```

Install dependencies:
```
# yum install -y git
```

Clone this repo:
```
# git clone https://github.com/gemini-project/gemini.git
```

Clone the Kubernetes Contrib repo:
```
# git clone https://github.com/gemini-project/contrib.git
```

Update group_vars/all.yml and copy the contents to ~/contrib/ansible/group_vars/all.yml

Rename host_vars/gemini_master_example to host_vars/${GEMINI_MASTER_FQDN_OR_IP} then edit the file
according to your deployment environment.

Replace gem-master-example in inventory/gemini-master with ${GEMINI_MASTER_FQDN_OR_IP}

Run the pre-setup script to populate the gemini ansible roles. For example:
```
# pwd
/root/gemini/ansible

# ./pre-setup.sh 
Cloning into '/root/gemini/ansible/roles/ansible-controller'...
remote: Counting objects: 20, done.
remote: Total 20 (delta 0), reused 0 (delta 0), pack-reused 20
...
total 28
drwxr-xr-x. 7 root root 4096 Mar 26 06:21 .
drwxr-xr-x. 7 root root 4096 Mar 26 06:20 ..
drwxr-xr-x. 5 root root   74 Mar 26 06:21 ansible-controller
drwxr-xr-x. 7 root root 4096 Mar 26 06:21 coreos-cloudinit
drwxr-xr-x. 9 root root 4096 Mar 26 06:21 dnsmasq
drwxr-xr-x. 9 root root 4096 Mar 26 06:21 httpd
-rw-r--r--. 1 root root  690 Mar 26 06:18 README.md
drwxr-xr-x. 9 root root 4096 Mar 26 06:21 tftp
-> Your Gemini Ansible roles have been successfully created
```

Run the setup script to deploy the gemini-master node:
```
# pwd
/root/gemini/ansible

# ./setup.sh
```

The setup script should complete with a successful Ansible playbook run:
```
PLAY RECAP *********************************************************************
kube-master                : ok=266  changed=78   unreachable=0    failed=0
kube-node-1                : ok=129  changed=39   unreachable=0    failed=0
kube-node-2                : ok=128  changed=39   unreachable=0    failed=0
```

Login to the Kubernetes master:
```
# ssh core@kube-master
```

Verify the Kuberenetes cluster is up:
```
# kubectl cluster-info
Kubernetes master is running at http://localhost:8080
Elasticsearch is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/elasticsearch-logging
Heapster is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/heapster
Kibana is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kibana-logging
KubeDNS is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kube-dns
Grafana is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana
InfluxDB is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb

# kubectl get nodes
NAME          LABELS                               STATUS    AGE
kube-node-1   kubernetes.io/hostname=kube-node-1   Ready     34m
kube-node-2   kubernetes.io/hostname=kube-node-2   Ready     34m
```

Make sure the STATUS shows Ready for each node. You are now ready to deploy Kubernetes resources. Try one of the [examples](https://github.com/kubernetes/kubernetes/tree/master/examples) from the Kubernetes project repo or the Gemini [web server](../../examples/web.yml) example.
