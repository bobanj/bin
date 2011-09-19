#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Please specify the mount point to unmount"
  exit -1
fi

mount_point=$1
if [ ! -d "${mount_point}" ]; then
    echo "The mount point isn't available." >&2
    exit 1
fi

mount_point=$(cd $mount_point && pwd)
device_name=$(df "${mount_point}" 2>/dev/null | tail -1 | grep "${mount_point}" | cut -d' ' -f1)
if [ -z "${device_name}" ]; then
    echo "The mount point didn't mount disk image." >&2
    exit 1
fi

umount "${mount_point}"
if [ $? -ne 0 ]; then
    echo "Could not unmount." >&2
    exit $?
fi

hdiutil detach -quiet $device_name
