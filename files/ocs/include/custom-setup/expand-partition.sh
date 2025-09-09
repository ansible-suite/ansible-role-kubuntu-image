#!/bin/bash

### Expands the last partition to the rest of the disk

set -eu

## Resize the partition
parted -s "$SETUP_DISK_PATH" resizepart "$SETUP_PART" 100%


## Expand the filesystem

# detect filesystem type
fstype="$(blkid -s TYPE -o value "$SETUP_PART_PATH")"

# expand the filesystem according to the type
case "$fstype" in
    ext4|ext3|ext2)
        e2fsck -f "$SETUP_PART_PATH"
        resize2fs "$SETUP_PART_PATH"
        ;;
    *)
        echo "!! Unknown or unsupported filesystem: $fstype"
        exit 1
        ;;
esac
