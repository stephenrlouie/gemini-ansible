#!/bin/bash

############
# GET OPTS #
############

function usage {
  echo "        -c <number> - Specifies how many clients to start up"
  echo "        -h - Brings up this help text"
  exit
}

while getopts ":hc:" opt; do
  case $opt in
    c)
      PXE_COUNT=$OPTARG
      ;;
    h)
      usage
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

######################
# DEPLOY PXE CLIENTS #
######################
if [ $PXE_COUNT ]
  then
    for (( i=1; i <= $PXE_COUNT; i++ ))
      do
        vmName="node-$i"
        
        isPresent=$(VBoxManage list vms | grep "$vmName")

        if [ ! -z "$isPresent" ];
        then
            VBoxManage controlvm $vmName poweroff 
            VBoxManage unregistervm $vmName --delete
        fi

        mac=$(printf "%0.12x" "$i";);
        if [[ ! -e $vmName.vdi ]]; then # check to see if PXE vm already exists
            echo "deploying pxe: $i"
            VBoxManage createvm --name $vmName --register;
            VBoxManage createhd --filename $vmName --size 8192;
            VBoxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAHCI
            VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vmName.vdi
            VBoxManage modifyvm $vmName --ostype Ubuntu --boot1 net --memory 2048;
            VBoxManage modifyvm $vmName --nic1 intnet --intnet1 prov --nicpromisc1 allow-all;
            VBoxManage modifyvm $vmName --nictype1 82540EM --macaddress1 $mac --nicspeed1 125000;

            VBoxManage modifyvm $vmName --nic2 nat --nicpromisc2 allow-all;
            VBoxManage modifyvm $vmName --nictype2 82540EM;
            
            VBoxManage startvm $vmName --type headless;
        fi
      done
fi
