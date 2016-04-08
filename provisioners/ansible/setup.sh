#!/bin/bash

inventory=${INVENTORY:-gemini-master}
playbook=${PLAYBOOK:-gemini-master.yml}

ansible-playbook -i ${inventory} ${playbook} $@
