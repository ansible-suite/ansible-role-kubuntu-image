#!/bin/bash

### Sets the hostname
# This script tries to set the hostname in the following order:
#   1. Statically, if "$SETUP_HOSTNAME" is nonempty, set hostname to its value
#   2. Dynamically, if "$SETUP_NETWORK_IFACE" is nonempty, using reverse DNS lookup of the IP of the interface

set -eu

## Determine the hostname
if [[ -n "$SETUP_HOSTNAME" ]]; then

    # define hostname statically
    hostname="$SETUP_HOSTNAME"

elif [[ -n "$SETUP_NETWORK_IFACE" ]]; then

    # get the IP of the network interface
    ipv4_address="$(ip -4 addr show $main_adapter_name | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+')"

    # get the hostname by reverse lookup
    hostname="$(dig -x "$ipv4_address" +short | sed 's/\.$//')"

fi


## Set the hostname if it was determined
if [ -n "$hostname" ]; then

    # save the hostname to /etc/hostname
    echo "$hostname" > /etc/hostname

    # modify hostname-based entries in /etc/hosts
    sed -i -e $'s/127.0.1.1.*/127.0.1.1\t'"$hostname"'/' /etc/hosts

    # set the hostname now
    hostname "$hostname"

fi
