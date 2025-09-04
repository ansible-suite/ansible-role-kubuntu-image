#!/bin/sh
set -eux

# 1. Determine target disk
$target="{% if kubuntu_image_clone_disk is defined %}{{ kubuntu_image_clone_disk }}{% endif %}"

if [ -z "$target" ]; then
    # Pick first non-USB disk (fallback)
    disk=$(lsblk -nrdo NAME,TYPE | awk '$2=="disk"{print $1}' | while read d; do
        if ! udevadm info --query=property --name=/dev/$d | grep -q '^ID_BUS=usb'; then
            echo $d
            break
        fi
    done)
    target="/dev/$disk"
fi

echo ">> Using target disk: $target"

# 2. Write image (from ISO /cdrom)
dd if=/cdrom/{{ kubuntu_image_live_img_path | quote }} of="$target" bs=16M status=progress conv=fsync

# 3. Reload partition table
partprobe "$target" || true
sleep 2

# 4. Find last partition
part=$(parted -sm "$target" print | awk -F: '$1 ~ /^[0-9]+$/ {num=$1} END{print $1}')
echo ">> Using partition number: $part"
case "$target" in
    *[0-9]) partpath="${target}p${part}" ;;
    *)      partpath="${target}${part}" ;;
esac
echo ">> Using partition: $partpath"

# 5. Expand partition to end of disk
parted -s "$target" resizepart "$part" 100%

# 6. Expand filesystem
# Detect filesystem type
fstype=$(blkid -s TYPE -o value "$partpath")

case "$fstype" in
    ext4|ext3|ext2)
        resize2fs "$partpath"
        ;;
    *)
        echo "!! Unknown or unsupported filesystem: $fstype"
        exit 1
        ;;
esac

# 7. Sync and reboot
sync
echo ">> Deployment complete, rebooting..."
reboot -f
