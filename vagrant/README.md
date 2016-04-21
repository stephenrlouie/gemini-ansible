# Table of Contents
- [High Level View] (#high-level-view)
- [Deployment] (#deployment)
- [Testing the Cluster] (#testing-the-cluster)
- [Remove Managed Nodes] (#remove-managed-nodes)
- [Demo] (#demo)
- [Tips] (#tips)

#High Level View: 
![alt text] (https://github.com/gemini-project/gemini/blob/master/docs/design/images/high-level.png "High Level View")


##Gemini Master 
Gemini is a cluster manager that simplifies deploying and operating clustering systems. Gemini uses [Kubernetes] (http://Kubernetes.io/) + [CoreOS] (https://coreos.com/) + [Cisco UCS] (http://www.cisco.com/c/en/us/products/servers-unified-computing/index.html) for it's initial reference implementation. This repository creates the **_Gemini Master_** who will be managing the installation / configuration of Kubernetes on CoreOS nodes. These controlled nodes will be called **_Managed Nodes_**. Managed Nodes will be blank machines started via the virtualbox CLI and instructed to PXE boot from the Gemini Master.

Requirements: git, [Virtualbox] (https://www.virtualbox.org/wiki/Downloads), [Vagrant] (https://www.vagrantup.com/downloads.html) 


#**Deployment**
1. Clone the gemini repo and move to the Vagrant directory
 ```
 git clone https://github.com/gemini-project/gemini.git && cd ~/gemini/vagrant
 ```

2. Build Gemini Master Image. **Time: ~30 Minutes** 
 
 This step takes significant time because building the gemini master requires downloading large binaries that must be served to the cluster, such as the Kubernetes, Flannel and pypy binaries. Taking the download time once here will save significant time when deploying the cluster.
    
   ```
   vagrant up
   ```

3. Create Managed Nodes. **Time: 1 Minute per node**
Might have to restart the VM's in Virtualbox so they all PXE boot. Issue: [#7] (https://github.com/gemini-project/gemini/issues/7)
    ```
    cd create_cluster
    ./cluster.sh -c <number_of_nodes>
    ```

4. Build Kubernetes Cluster via contrib. **Time: ~10 Minutes**
   ```
   vagrant ssh gem_master
   ```

  Set up your inventory file at `contrib/ansible` to describe your desired cluster. Lastly, run the setup.sh script at `contrib/ansible` to configure the cluster.
   ```
   ./setup.sh
   ```

 This table illustrates how we set up Nodes, MACs and IPs. The maximum number of nodes is 10. You must edit the ```dnsmasq.conf``` to add more static mappings for more nodes and restart the dnsmasq service


 |Node Number | MAC Address       | IP          |
 | ---------- | ----------------- | ----------- | 
 | Node-01    | 00:00:00:00:00:01 | 10.10.10.11 |
 | Node-02    | 00:00:00:00:00:02 | 10.10.10.12 |
 | Node-03    | 00:00:00:00:00:03 | 10.10.10.13 |
 | Node-04    | 00:00:00:00:00:04 | 10.10.10.14 |
 

#Testing the Cluster
1. ssh into the gem master
 ```
 vagrant ssh gem_master
 ```

2. ssh into the kube master node (whoever you assigned it to in your inventory file)

3. Check Kubernetes status and nodes on the kube master node

 ```
 kubectl cluster-info
 kubectl get nodes
 ```

4. Create file `web.yml` by copy pasting our example [web app] (https://raw.githubusercontent.com/gemini-project/gemini/master/examples/web.yml).

5. Create the pod, replication controller and service.
 
 `sudo kubectl create -f web.yml`

6. Check status of the pod, rc and service.

 `kubectl get pod,rc,svc`
 
 `kubectl describe pod <pod-name>`

 ![alt text] (https://github.com/gemini-project/gemini/blob/master/docs/design/images/accessWebApp.png)


7. curl the pod `curl http://192.168.2.5:30302` (As seen above)

#Remove Managed Nodes
```
cd gemini/vagrant/create_cluster
./cleanup.sh -c <number_of_nodes>
```

#Demo
[Streaming Link] (https://cisco.webex.com/ciscosales/ldr.php?RCID=1685081ad9ff3361b1fcc68ceb24a282)

#Tips
Since you'll be cycling through managed nodes for development / testing it might be useful to add this to your profile / bashrc.
 
   `export ANSIBLE_HOST_KEY_CHECKING=False`
