
# Table of Contents
- [High Level View] (#high-level-view)
- [Overview] (#overview)
- [First Time Setup] (#first-time-setup)
- [Testing the Cluster] (#testing-the-cluster)
- [Refreshing Managed Nodes] (#refreshing-managed-nodes)
- [Demo] (#demo)
- [Tips] (#tips)
- [Known Issues] (#known-issues)

#High Level View: 
![alt text] (https://github.com/gemini-project/gemini/blob/master/docs/design/images/high-level.png "High Level View")


##Gemini Master 
 - Gemini is a cluster manager that simplifies deploying and operating clustering systems. Gemini uses [Kubernetes] (http://kubernetes.io/) + [CoreOS] (https://coreos.com/) + [Cisco UCS] (http://www.cisco.com/c/en/us/products/servers-unified-computing/index.html) for it's initial reference implementation.
 - This repository creates the **_Gemini Master_** who will be managing the installation / configuration of kubernetes on CoreOS nodes. These controlled nodes will be called **_Managed Nodes_**.
 - Managed Nodes
   - **PXE Boot Managed Nodes**: Blank Machines started in virtualbox and put on an internal network and told to network boot.
 - This Repository will only concern itself with the **_Gemini Master_** and the **_PXE Boot Managed Nodes_**

#**Overview**
1. Deploy pre-built Image
2. Pull contrib code
3. Create Managed Nodes
4. Configure inventory file and run `contrib/ansible/setup.sh`

#First Time Setup
1. Deploys the pre-made image. **Time: 30 Seconds** (If you've already pulled *stephenrlouie/gemini_master*, if not a download of the image will begin ~800MBs)
    
   ```
   vagrant up
   ```

2. Pull contrib code **Time: 30 Seconds**
 - The gemini master must have a copy of the contrib project to deploy to managed nodes.
 - *Only supports [kubernetes/contrib] (https://github.com/kubernetes/contrib)*

   ```
   vagrant ssh master
   git clone https://github.com/kubernetes/contrib 
   ```

 - Uncomment the **python_ansible_interpreter** line in `contrib/ansible/group_vars/all.yml`
   - Tells CoreOS where it can find python

 - Add these lines to the bottom of `conrib/ansible/group_vars/all.yml`
   - Tells nodes to pull binaries from the gemini_master instead of the internet, greatly reducing cluster setup time.
 
 ```
 flannel_download_url_base: http://192.168.2.2/downloads/bins/flannel/
 kube_download_url_base: http://192.168.2.2/downloads/bins/kubernetes/v{{ kube_version }}/
 pypy_base_url: http://192.168.2.2/downloads/bins/pypy/v{{ pypy_version }}/
 ```
   - Configures the right adapters for flannel and etcd

 ```
 #The adapter to use for flannel
 flannel_opts: "--iface=eth1"

 #The adapter to use for etcd
 etcd_interface: "eth1"
 ```


3. Create Managed Nodes. **Time: 1 Minute per node**
 1. PXE-Boot Managed Nodes:
   - For more cluster options `./cluster.sh -h`
     - Might have to restart the VM's from Virtualbox so they all PXE boot. Issue: #7
    ```
    cd create_cluster
    ./cluster.sh -c <number_of_nodes>
    ```

4. Configure inventory file and run `contrib/ansible/setup.sh` script. **Time: ~10 Minutes**
 - The Maximum number of nodes is 11. You must edit the dhcpd.conf to add more static mappings for more nodes and restart the dhcpd service
 - This table is just a sample; static mapping will continue up to mac 00:00:00:00:0b in the same pattern shown below. See the DHCP.conf for details.

 |Node Number | MAC Address       | IP          |
 | ---------- | ----------------- | ----------- | 
 | Node-01    | 00:00:00:00:00:01 | 192.168.2.3 |
 | Node-02    | 00:00:00:00:00:02 | 192.168.2.4 |
 | Node-03    | 00:00:00:00:00:03 | 192.168.2.5 |
 | Node-04    | 00:00:00:00:00:04 | 192.168.2.6 |
 
 - An example inventory file might look like [this] (https://gist.github.com/stephenrlouie/94497c7035ff0c07fa6f)
 - Lastly, run the setup.sh script to configure the cluster.
 
 `INVENTORY=inventory ./setup.sh --private-key ~/.ssh/ansible_rsa -u core`


#Testing the Cluster
1. ssh into the kube master node (whoever you assigned it to in your inventory file)
 `vagrant ssh master`

2. Check nodes

 `kubectl get nodes`

3. Create file `web.yml` by copy pasting this [gist] (https://gist.github.com/danehans/cb744bd10084175ccc44). Its also found in our examples.

4. Create the pod, replication controller and service.
 
 `sudo kubectl create -f web.yml`

5. Check status of the pod, rc and service.

 `kubectl get pod,rc,svc`
 
 - Wait until the pod is in the *Running* state *(5-10 minutes)*
 - Once it is running get the node IP

 `kubectl describe pod <pod-name>`

 ![alt text] (https://github.com/gemini-project/gemini/blob/master/docs/design/images/accessWebApp.png)


6. curl `http://192.168.2.5:30302` (As seen above)

#Refreshing Managed Nodes
 1. `./cleanup.sh -c <number_of_nodes>`
 2. `./cluster.sh -c <number_of_nodes>`

 - Repeat step 4 to re-deploy contrib

#Demo
- [Streaming Link] (https://cisco.webex.com/ciscosales/ldr.php?RCID=1685081ad9ff3361b1fcc68ceb24a282)

#Tips
 - Since you'll be cycling through managed nodes for development / testing it might be useful to add this to your profile / bashrc.
 
   `export ANSIBLE_HOST_KEY_CHECKING=False`

- You can hit the web app from your favorite web browser if you expose the NAT port on the kube node running the web app. 
 1. Right click on the kube_master VM in virtualbox 
 2. *Settings* -> *Network* -> *Port Forwarding*. (On the Adapter that is attached to *NAT*)
 3. Add a rule:
    - Protocol: TCP
    - Host Port: 3030
    - Guest Port: 30302
 4. Open a web browser and go to `localhost:3030` or `http://127.0.0.1:3030`

#Known Issues
 - See [open issues] (https://github.com/gemini-project/gemini/issues). All work-arounds will be posted under its corresponding issue.
