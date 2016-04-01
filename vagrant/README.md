#Gemini Master 
 - Gemini is a cluster manager that simplifies deploying and operating clustering systems. Gemini uses [Kubernetes] (http://kubernetes.io/) + [CoreOS] (https://coreos.com/) + [Cisco UCS] (http://www.cisco.com/c/en/us/products/servers-unified-computing/index.html) for it's initial reference implementation.
 - This repository creates the **_Gemini Master_** who will be managing the installation / configuration of kubernetes on CoreOS nodes. These controlled nodes will be called **_Managed Nodes_**.
 - Managed Nodes
   - **PXE Boot Managed Nodes**: Blank Machines started in virtualbox and put on an internal network and told to network boot.
 - This Repository will only concern itself with the **_Gemini Master_** and the **_PXE Boot Managed Nodes_**

##Demo
- [Streaming Link] (https://cisco.webex.com/ciscosales/ldr.php?RCID=1685081ad9ff3361b1fcc68ceb24a282)

##High Level View: 
![alt text] (https://github.com/stephenrlouie/gemini_images/blob/master/high-level.png "High Level View")

- You specify the three roles in the kubernetes/contrib file [inventory file] (https://github.com/kubernetes/contrib/blob/master/ansible/inventory.example.single_master).

##**Overview**
1. Pull pre-requisite images / tars
2. Create "build_master" image
3. Package "build_master" images
4. Add image to vagrant
5. Destroy build_master Image
6. Deploy pre-built Image
7. Pull contrib code
8. Create Managed Nodes
9. Configure inventory file and run contrib/ansible/setup.sh


 - Steps 2-5: Can be skipped but are here to save time for later deployments of the virtual environment.
   - These steps take up to 10 minutes to bring up the Gemini Master because we are yum updating, installing and configuring all the parts of the Gemini Master. By packaging up the image and adding it to Vagrant, the start up time goes from 10 minutes to 30 seconds. *It is highly recommended to package this build.*


##First Time Setup
1. Pull the cent image and tars required for Gemini Master (K8s tar, Flannel Tar)
 - **Time: 5 Minutes**
 
    `cd start_scripts`
    `./start.sh`

2. Create the master image.
 - This step will yum update, install, configure and start httpd, tftp, and dhcp. It creates a gemini master from scratch. 
 - **Time: 5-10 Minutes**

    `vagrant up build_master`

3. Package up the current image
 - This step will take the good image we made in step 2 and package it for later use and faster depoyment.
 - **Time: 1 Minute**

    ```
    vagrant package build_master --output <storage_path>/gemini_master.box
    ```
    
4. Add to vagrant's box list
 - This will take your pre-made image and make it known to Vagrant. You can view the Vagrant images by running `vagrant box list`
 - **Time: 30 Seconds**
    
    ```
    vagrant box add gemini_master <storage_path>/gemini_master.box
    ```
    
5. Destroys the build_master box. (build_master is there to create our *golden image*)
 - **Time: 10 Seconds**
    
    `vagrant destroy -f`

6. Deploys the pre-made image. *Must name the Vagrant reference gemini_master* See the Vagrantfile section for 'master' 
 - **Time: 30 Seconds**
    
    `vagrant up`

7. Pull contrib code
 - The gemini master must have a copy of the contrib project to deploy to managed nodes.
 
   ```
   vagrant ssh master
   git clone https://github.com/kubernetes/contrib 
   ```
 - *Only supports [kubernetes/contrib] (https://github.com/kubernetes/contrib)*

8. Create Managed Nodes
 1. PXE-Boot Managed Nodes:
   - For more cluster options `./cluster.sh -h`
    
    ```
    cd create_cluster
    ./cluster.sh -c <number_of_nodes>
    ```

9. Configure inventory file and run *contrib/ansible/setup.sh*
 - Both managed node start up methods will bring up machines with pre-selected MAC Addresses.
 
 This table is just a sample; static mapping will continue up to mac 00:00:00:00:0b in the same pattern shown below. See the DHCP.conf for details.

 |Node Number | MAC Address       | IP          |
 | ---------- | ----------------- | ----------- | 
 | Node-01    | 00:00:00:00:00:01 | 192.168.2.3 |
 | Node-02    | 00:00:00:00:00:02 | 192.168.2.4 |
 | Node-03    | 00:00:00:00:00:03 | 192.168.2.5 |
 | Node-04    | 00:00:00:00:00:04 | 192.168.2.6 |
 
 - An example inventory file might look like [this] (https://gist.github.com/stephenrlouie/94497c7035ff0c07fa6f)
 - Lastly, run the setup.sh script to configure the cluster.
 
 `INVENTORY=inventory ./setup.sh --private-key ~/.ssh/ansible_rsa -u core`


##Testing the Cluster
1. ssh into the kube master node (whoever you assigned it to in your inventory file)
 `vagrant ssh master`

2. Check nodes

 `kubectl get nodes`

3. Create file `web.yml` by copy pasting this [gist] (https://gist.github.com/danehans/cb744bd10084175ccc44). Its also found in our examples.
4. Create the pod, replication controller and service.
 
 `sudo kubectl create -f web.yml`

5. Check status of the pod, rc and service.

 `kubectl get pod,rc,svc`
 
 - Wait until the pod is in the *Running* state (can take up to 5 minutes)
 - Once it is running get the pod IP

 `kubectl describe pod <pod-name>`

6. curl http://*"POD IP Address":30302* (As seen above)

##Refreshing Managed Nodes
 - PXE Boot Managed Nodes
  - ./cluster.sh -c <number_of_nodes>

 - Repeat step 9 to re-deploy contrib

##Tips
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

##Known Issues
 - See [open issues] (https://github.com/gemini-project/gemini/issues). All work-arounds will be posted under its corresponding issue.
