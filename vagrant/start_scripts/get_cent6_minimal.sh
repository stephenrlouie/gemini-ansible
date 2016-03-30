#! /bin/bash

box=$(vagrant box list | grep "cent6_minimal")

if [ -z "$box" ] 
then
    vagrant box add cent6_minimal https://github.com/2creatives/vagrant-centos/releases/download/v6.4.2/centos64-x86_64-20140116.box
fi
