#!/bin/sh

mount_point=${1}
size=${2:-64}

if [ $# -ne 2 ]; then
  echo "Please specify a mount point (e.g. ~/volatile) and the size on MB"
  exit -1
fi

mkdir -p $mount_point
if [ $? -ne 0 ]; then
    echo "The mount point isn't available." >&2
    exit $?
fi

sector=$(expr $size \* 1024 \* 1024 / 512)
device_name=$(hdid -nomount "ram://${sector}" | awk '{print $1}')
if [ $? -ne 0 ]; then
    echo "Could not create disk image." >&2
    exit $?
fi

newfs_hfs $device_name > /dev/null
if [ $? -ne 0 ]; then
    echo "Could not format disk image." >&2
    exit $?
fi

mount -t hfs $device_name $mount_point
if [ $? -ne 0 ]; then
    echo "Could not mount disk image." >&2
    exit $?
fi

# hide the volume from the Finder
if [ -e /usr/bin/SetFile ]; then
    /usr/bin/SetFile -a V ${mount_point}
fi
