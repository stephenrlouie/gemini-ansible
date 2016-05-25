#!/bin/bash

base_dir=${BASE_DIR:-~/gemini-ansible/provisioners/ansible/roles}
contrib_base_dir=${CONTRIB_BASE_DIR:-~}

echo "-> Setting Up SSH"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#TODO: For loop that checks if ${base_dir}/$file exists before cloning the repos.
echo "-> Cloning Repos"
git clone https://github.com/gemini-project/contrib.git ${contrib_base_dir}/contrib
git clone https://github.com/gemini-project/ansible-role-docker.git ${base_dir}/docker
git clone https://github.com/stephenrlouie/ansible-role-foreman.git ${base_dir}/foreman

# Show the populated roles directory
echo "-> These are your Ansible roles"
ls -al ${base_dir}
ls -al ${contrib_base_dir}/contrib/ansible/roles

# Pre-setup complete
echo "-> Your Gemini Ansible roles have been successfully created"
