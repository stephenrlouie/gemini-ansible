#!/bin/bash

inventory=${INVENTORY:-inventory}
playbook=${PLAYBOOK:-playbooks/gem-master.yml}

ansible-playbook -i ${inventory} ${playbook} $@
