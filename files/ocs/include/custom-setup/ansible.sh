#!/bin/bash

### Runs ansible to perform early setup

## Extract the ansible site archive

# get a temporary directory
ansible_site="$(mktemp -d)"

# extract the archive
tar -xzf "$SETUP_ANSIBLE_SITE" -C "$ansible_site" --strip-components=1


## Initialize the environment

# install python3-venv
DEBIAN_FRONTEND=noninteractive apt -y install python3-venv

# run setup script
"$ansible_site/bin/setup"

# activate the environment
source "$ansible_site/bin/activate"


## Run the playbook locally
ansible-playbook-local "$ansible_site/$SETUP_ANSIBLE_PLAYBOOK"
