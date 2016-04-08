# Gemini Installation Guide

This guide walks through the steps for deploying Gemini to a baremetal
server cluster. At least 2 servers are required to support this deployment
type. One server is used as the Gemini Master and one or more servers are
used to run clustering software, such as [Kubernetes](http://kubernetes.io/).

**Note**: These steps will soon be replaced by a simple installation script.

## Before You Start

Make sure all servers are "racked and stacked" and connected to a network.

The server that acts as the Gemini Master needs to be installed with with
CentOS Linux 7. The Gemini team has been using the [CentOS 7 minimal ISO](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso). SSH to the Gemini Master after the CentOS 7 installation is complete and
the server has rebooted.

The Gemini Master uses IPMI to power cycle cluster nodes. Make sure cluster nodes
are configured for IPMI and the IPMI IP address is reachable from the Gemini Master.

PXE should be the first boot option for cluster nodes. This allows the cluster nodes
to have their Operating System provisioned by the Gemini Master.

Install Ansible:
```
# rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
# yum -y install ansible
```

Install dependencies:
```
# yum install -y git ipmitool
```

Clone the Gemini repo:
```
# git clone https://github.com/gemini-project/gemini.git
```

Change to the Gemini Ansible directory:
```
# cd gemini/provisioners/ansible/
```

Run the pre-setup script to populate the gemini ansible roles:
```
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

Modify ```group_vars/all.yml``` with the specifics of your deployment environment.

Run the setup script to deploy the Gemini Master node:
```
# ./setup.sh
```

The setup script should complete with a successful Ansible playbook run:
```
...
PLAY RECAP ********************************************************************
my-gemini-master               : ok=57   changed=39   unreachable=0    failed=0
```

The Gemini Master uses [ipmitool](http://linux.die.net/man/1/ipmitool) for remotely managing
cluster nodes. Test connectivity to the IPMI address of each cluster node.
```
# ping ${SERVER_IPMI_IP_ADDRESS}
```

Power cycle each cluster node. **Note:** The boot order for cluster nodes must start with PXE:
```
# ipmitool -H ${SERVER_IPMI_IP_ADDRESS} -U ${SERVER_IPMI_USERNAME} -P${SERVER_IPMI_PASSWORD} power cycle
```

The cluster nodes power cycle and are provisioned an Operating System by the Gemini Master. Make sure
you can SSH from the Gemini Master to each cluster using the IP address(es) defined in group_vars/all.yml.
**Note**: You should not be prompted for a password when SSH'ing to each cluster node.
```
[root@my-gemini-master]# ssh core@${MY_CLUSTER_NODE_IP}
Last login: Fri Apr  8 06:48:44 2016 from 10.30.118.132
CoreOS stable (1010.1.0)
Update Strategy: No Reboots
core@kube-node01 ~ $
```

Exit your test SSH session and change to the Contrib Ansible directory:
```
# cd ~/contrib/ansible
```

Create the inventory of cluster nodes. You must define at least one node by
IP address or FQDN for each role within the inventory file.
```
# cp inventory.example.single_master inventory
# vi inventory
```

Modify ```group_vars/all.yml``` with at least the following:
```
ansible_ssh_user: core
ansible_python_interpreter: "PATH=/opt/bin:$PATH python"
```

**Optionally** you can add the following entries to ```group_vars/all.yml```
to improve the download speed of cluster binaries. Replase ${YOUR_GEMINI_MASTER_IP}
with the IP address of your Gemini Master:
```
# The URL to download Kubernetes binaries for CoreOS
kube_download_base_url: "http://${YOUR_GEMINI_MASTER_IP}/releases/kubernetes/v{{ kube_version }}"

# The URL to download Flannel binaries tar file for CoreOS
flannel_download_base_url: "http://${YOUR_GEMINI_MASTER_IP}/releases/flannel"

# The URL to download Pypy binaries tar file for CoreOS
pypy_base_url: "http://${YOUR_GEMINI_MASTER_IP}/releases/pypy/v{{ pypy_version }}"
```

Run the setup script to deploy the cluster node(s):
```
# ./setup.sh
```

The setup script should complete with a successful Ansible playbook run:
```
...
PLAY RECAP ********************************************************************
kube-node01               : ok=57   changed=39   unreachable=0    failed=0
```

Login to the Kubernetes master:
```
# ssh core@kube-node01
```

Verify the Kuberenetes cluster is up:
```
core@kube-node01 ~ $ kubectl cluster-info
Kubernetes master is running at http://localhost:8080
Elasticsearch is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/elasticsearch-logging
Heapster is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/heapster
Kibana is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kibana-logging
KubeDNS is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kube-dns
Grafana is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana
InfluxDB is running at http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb

core@kube-node01 ~ $ kubectl get nodes
NAME          LABELS                               STATUS    AGE
kube-node-1   kubernetes.io/hostname=kube-node-1   Ready     34m
```

Make sure the STATUS shows Ready for each node. You are now ready to deploy Kubernetes resources. Try one of the [examples](https://github.com/kubernetes/kubernetes/tree/master/examples) from the Kubernetes project repo or the Gemini [web server](../../examples/web.yml) example:
```
# wget --no-check-certificate https://raw.githubusercontent.com/gemini-project/gemini/master/examples/web.yml
# sudo kubectl create -f web.yml
```

Verify that the example rc/pod/svc are running:
```
core@kube-node01 ~ $ kubectl get rc,pod,svc
NAME         DESIRED         CURRENT       AGE
web          1               1             2m
NAME         READY           STATUS        RESTARTS   AGE
web-0yoyz    1/1             Running       0          2m
NAME         CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes   10.254.0.1      <none>        443/TCP    8m
web          10.254.212.64   nodes         80/TCP     2m
```

Verify you can curl the example service:
```
core@kube-node01 ~ $ curl kube-node01:30302
<!DOCTYPE html>
<html>
	<head>
		<title>mini_httpd on docker</title>
    <style>
      body {
          font-family: Arial,Helvetica Neue,Helvetica,sans-serif;
      }

      #address {
        text-align: center;
        border: thin solid black;
        padding: 1ex;
        margin-top: 2ex;
        margin-bottom: 2ex;
        max-width: 40ex;
        background-color: orange;
      }

      #address strong {
        font-size: 200%;
      }
    </style>
	</head>
	<body>
  <h1>Congratulations! It worked!</h1>

  This page is being served by <a href="">mini_httpd</a> running under Docker.

  <div id="address">
    <p><strong>12.16.47.9</strong></p>
</div>
	</body>
</html>
```

Congratulations!!!
