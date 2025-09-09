#!/bin/bash

### Runs a command in a chroot jail of the newly-cloned system

set -eu

## Define variables

# the directory of the newly-cloned system
target=/target

# the mount point for the setup directory
setup_mount_point="$target$SETUP_DIR_CHROOT"

# Define files and directories from current filesystem
# to be bind mounted to $target for somec features to work within chroot
bind_mount_files="/dev /proc /sys /run"

# Define variables for /etc/resolv.conf bind mount workaround
resolv=/etc/resolv.conf
resolv_bup="$resolv.bup"


## Prepare the chroot

# Mount target
mkdir -p "$target" && mount "$SETUP_PART_PATH" "$target"

# Bind mount defined files and directories to target
for f in $bind_mount_files; do
    mount --bind "$f" "$target$f"
done

# Set up /etc/resolv.conf
mv "$target$resolv" "$target$resolv_bup"
touch "$target$resolv"
mount --bind "$resolv" "$target$resolv"


# Bind mount this directory to $TARGET/mnt/setup
mkdir -p "$setup_mount_point" && mount --bind "$(dirname "$0")" "$setup_mount_point"


## Perform chroot to target with the specified command
chroot "$target" "$@"


## Cleanup

# Unmount the setup directory
umount "$setup_mount_point"
rmdir "$setup_mount_point"

# Restore /etc/resolv.conf
umount "$target$resolv"
mv "$target$resolv_bup" "$target$resolv"

# Unmount helper directories and files
for f in $bind_mount_files; do
    umount "$target$f"
done

# Unmount target
umount "$target"
