#!/bin/bash

### Performs post-clone initial setup (main part)

set -eu

## Source the env variables
source "$(dirname "$0")/env"


## Connect to the network
dhclient "$SETUP_NETWORK_IFACE"


## Expand the main partition
bash "$SETUP_DIR/expand-partition.sh"


## Run setup-chroot.sh in a chroot
bash "$SETUP_DIR/ocs-chroot.sh" bash "$SETUP_DIR_CHROOT/setup-chroot.sh"
