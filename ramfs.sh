#!/bin/bash

# From: http://blogs.nullvision.com/?p=275

ramfs_size_mb=512
mount_point=/private/ramfs

ramfs_size_sectors=$((${ramfs_size_mb}*1024*1024/512))
ramdisk_dev=`hdid -nomount ram://${ramfs_size_sectors}`
newfs_hfs -v 'Ramdisk HD' ${ramdisk_dev}
mkdir -p ${mount_point}
mount -o noatime -t hfs ${ramdisk_dev} ${mount_point}
# hide the volume from the Finder
if [ -e /usr/bin/SetFile ]; then
	/usr/bin/SetFile -a V ${mount_point}
fi
chown root:wheel ${mount_point}
chmod 1777 ${mount_point}