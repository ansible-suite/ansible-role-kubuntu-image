#!/bin/bash

### Performs post-clone initial setup (chrooted part)

set -eu

## Source the env variables
source "$(dirname "$0")/env"


## Log to file
exec &> >(tee "$SETUP_CHROOT_LOGFILE")


## Set the hostname
bash "$SETUP_DIR/hostname.sh"


## Run ansible
bash "$SETUP_DIR/ansible.sh"
