#!/bin/bash
# ------------------------------------------------------------
# Parted - Create a new partition
#

# Determine partition's disk-size (based on start- & end-bytes)
for EACH_DEVICE in /dev/sd? ; do parted -m "${EACH_DEVICE}" unit B print; done;
#  |--> Set start-byte to 1 byte past the LAST partition's end-byte (in B)
#  |--> Set end-byte to the total disk size (in B)
#
### EXAMPLE --> for EACH_DEVICE in /dev/sd? ; do parted -m "${EACH_DEVICE}" unit B print; done;
#
# BYT;
# /dev/sda:429496729600B:scsi:512:512:msdos:VMware Virtual disk:;
# 1:1048576B:1074790399B:1073741824B:xfs::boot;
# 2:1074790400B:107374182399B:106299392000B:::lvm;
#
# ^-- Device name is '/dev/sda' (based on the header line's FIRST value of "/dev/sda)"
#      |--> DEVICE="/dev/sda";
#
# ^-- The last (second, in this case) partition ends at byte 107374182399, so start new partition ONE byte after it via:  107374182399+1 = 107374182400
#      |--> START_BYTE="107374182400B";
#
# ^-- The disk's maximum capacity ends at byte 429496729600, so end the new partition ONE byte before it via:  429496729600-1 = 429496729599
#      |--> END_BYTE="429496729599B";
#
# ^-- The filesystem type for the currently boot partition on this device is "xfs" (based on the '1:...' line's FIFTH value, "xfs")
#      |--> FS_TYPE="xfs";
#

#
# Determine partition-type based-on currently-existent partition types
# !!! AUTOMATICALLY DONE VIA SCRIPT, BELOW !!!
#  |--> parted "/dev/sda" "print";  # Or without targeting a specific device:   parted -l;
#        |--> If target disk's "Partition Table" has value "msdos", then it is formatted using MBR, so use "primary" partition type
#        |--> If target disk's "Partition Table" has value "gpt", then it is formatted using GPT, so use "logical" partition type
#

if [ 1 ]; then

DEVICE="/dev/sda";           #  !!! ENTER VALUE(S), HERE !!!  (see above for determining this parameter's value)
START_BYTE="107374182400B";  #  !!! ENTER VALUE(S), HERE !!!  (see above for determining this parameter's value)
END_BYTE="429496729599B";    #  !!! ENTER VALUE(S), HERE !!!  (see above for determining this parameter's value)
FS_TYPE="xfs";               #  !!! ENTER VALUE(S), HERE !!!  (see above for determining this parameter's value)
MOUNT_PATH="/EXAMPLE-PATH";  #  !!! ENTER VALUE(S), HERE !!!  (see above for determining this parameter's value)

PART_TYPE="primary"; if [ $(parted "${DEVICE}" print | grep '^Partition Table:' | grep 'gpt' 1>/dev/null 2>&1; echo $?;) -eq 0 ]; then PART_TYPE="logical"; fi;

echo "";
echo "Calling  [ parted \"${DEVICE}\" mkpart \"${PART_TYPE}\" \"${FS_TYPE}\" \"${START_BYTE}\" \"${END_BYTE}\"; ]  ...";
parted "${DEVICE}" mkpart "${PART_TYPE}" "${FS_TYPE}" "${START_BYTE}" "${END_BYTE}";

echo "";
echo "Constructing a \"${FS_TYPE}\" filesystem on device \"${DEVICE}\"";
echo "[SCRIPT-CALL]>  mkfs.${FS_TYPE} \"${DEVICE}\";";
echo "";
mkfs.${FS_TYPE} "${DEVICE}";


echo "";
echo "Obtaining UUID for device \"${DEVICE}\" from listings in \"/dev/disk/by-uuid\"...";
DEVICE_UUID=$(ls -al "/dev/disk/by-uuid" | grep "^l" | grep "../../$(basename ${DEVICE})\$" | awk '{print $9}';);
if [ -n "${DEVICE_UUID}" ]; then
	echo "";
	echo "Info:  Resolved device \"${DEVICE}\" to UUID \"${DEVICE_UUID}\"";
	FSTAB_DEVICE="UUID=\"${DEVICE_UUID}\"";
else
	echo "";
	echo "Info:  Unable to resolve device \"${DEVICE}\" to a UUID";
	FSTAB_DEVICE="${DEVICE}";
fi;

FSTAB_VALS_1=$(cat '/etc/fstab' | grep '^/dev' | head -n 1 | awk '{print $1}';); echo "FSTAB_VALS_1 = \"${FSTAB_VALS_1}\"";
FSTAB_VALS_2=$(cat '/etc/fstab' | grep '^/dev' | head -n 1 | awk '{print $2}';); echo "FSTAB_VALS_2 = \"${FSTAB_VALS_2}\"";
FSTAB_VALS_3=$(cat '/etc/fstab' | grep '^/dev' | head -n 1 | awk '{print $3}';); echo "FSTAB_VALS_3 = \"${FSTAB_VALS_3}\"";
FSTAB_VALS_4=$(cat '/etc/fstab' | grep '^/dev' | head -n 1 | awk '{print $4}';); echo "FSTAB_VALS_4 = \"${FSTAB_VALS_4}\"";
FSTAB_VALS_5=$(cat '/etc/fstab' | grep '^/dev' | head -n 1 | awk '{print $5}';); echo "FSTAB_VALS_5 = \"${FSTAB_VALS_5}\"";
FSTAB_VALS_6=$(cat '/etc/fstab' | grep '^/dev' | head -n 1 | awk '{print $6}';); echo "FSTAB_VALS_6 = \"${FSTAB_VALS_6}\"";

echo "";
echo "To mount device on-bootup (permanently add mount), add the following line to the \"/etc/fstab\" config file:";
echo "${FSTAB_DEVICE} ${MOUNT_PATH} ${FSTAB_VALS_3} ${FSTAB_VALS_4} ${FSTAB_VALS_5} ${FSTAB_VALS_6}";

if [ $(cat "/etc/fstab" | grep "^${DEVICE}" 1>/dev/null 2>&1; echo $?;) -eq 0 ]; then
	# Device mounted at-bootup by its device-path (best practice is to use device UUID)
	echo "";
	echo "Info:  Found boot config (by-path) for device \"${DEVICE}\" in \"/etc/fstab\":";
	echo "Warning:  Best practice is to mount by device UUID, as it remains static per-device (but device paths & labels are not forced to be static)";
	cat "/etc/fstab" | grep "^${DEVICE}";
elif [ $(cat "/etc/fstab" | grep "^UUID=\"${DEVICE_UUID}\"" 1>/dev/null 2>&1; echo $?;) -eq 0 ]; then
	# Device mounted at-bootup by its UUID
	echo "";
	echo "Info:  Found boot config (by-UUID) for device \"${DEVICE}\" in \"/etc/fstab\":";
	cat "/etc/fstab" | grep "^${DEVICE}";
fi;

echo "";
echo "Info: Showing file system disk space usage";
echo "[SCRIPT-CALL]>  df -h | grep -v '^tmp' | grep -v '^dev';";
df -h | grep -v '^tmp' | grep -v '^dev';

echo "";
echo "Info: Listing partition tables for device \"${DEVICE}\"";
echo "[SCRIPT-CALL]>  fdisk -l \"${DEVICE}\"";
fdisk -l "${DEVICE}";

echo "";
echo "Mount your newly-created partition via command:";
echo "   mkdir -p \"${MOUNT_PATH}\";";
echo "   sudo mount -t \"${FS_TYPE}\" \"/dev/[YOUR_NEW_PARTITION]\" \"${MOUNT_PATH}\";";
echo "";

fi;
# |
# |--> Running this yielded output [ Information: You may need to update /etc/fstab. ]

### reboot;  # !!! MANUALLY REBOOT SERVER, WHEN READY !!! <-- need to find command to rebuild "/etc/fstab" or whatever file contains current partitions/mounts/etc. WITHOUT restarting/forcing downtime


# ------------------------------------------------------------
# Resize a given partition

### REFER TO:  https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-disk-storage-parted-resize-part


# ------------------------------------------------------------
# Partition un-partitioned disk(s)

### UNDER CONSTRUCTION AS-OF 20200305-225420  -->  wget "https://raw.githubusercontent.com/mcavallo-git/cloud-infrastructure/master/usr/local/sbin/partition_unpartitioned_disks" -O "/usr/local/sbin/partition_unpartitioned_disks" -q && chmod 0755 "/usr/local/sbin/partition_unpartitioned_disks" && /usr/local/sbin/partition_unpartitioned_disks;


# ------------------------------------------------------------
# Additional disk-info packages/commands/tools

# Determine FS (filesystem) type based on existing filesystem(s)
df -h --output="source,fstype" | grep -v '^tmp' | grep -v '^dev';

lsblk -p -n -o KNAME,TYPE,MOUNTPOINT;

fdisk -l | grep sectors | grep '^Disk';

# Get filesystem-type(s) for the current system
df -h --output="source,fstype";
lsblk -fp;


# ------------------------------------------------------------
#
# Citation(s)
#
#   access.redhat.com  |  "Chapter 7. Kernel crash dump guide Red Hat Enterprise Linux 7 | Red Hat Customer Portal"  |  https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/kernel_administration_guide/kernel_crash_dump_guide
#
#   access.redhat.com  |  "13.4. Resizing a Partition Red Hat Enterprise Linux 6 | Red Hat Customer Portal"  |  https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/s2-disk-storage-parted-resize-part
#
#   help.ubuntu.com  |  "Kernel Crash Dump"  |  https://help.ubuntu.com/lts/serverguide/kernel-crash-dump.html
#
#   linux.die.net  |  "parted(8): partition change program - Linux man page"  |  https://linux.die.net/man/8/parted
#
#   opensource.com  |  "How to partition a disk in Linux | Opensource.com"  |  https://opensource.com/article/18/6/how-partition-disk-linux
#
#   serverfault.com  |  "ubuntu - How to repair the fstab file with current configuration - Server Fault"  |  https://serverfault.com/a/333742
#
#   stackoverflow.com  |  "linux - How to make parted always show the same unit - Stack Overflow"  |  https://stackoverflow.com/a/6428709
#
#   unix.stackexchange.com  |  "storage - linux: How can I view all UUIDs for all available disks on my system? - Unix & Linux Stack Exchange"  |  https://unix.stackexchange.com/a/660
#
#   wiki.archlinux.org  |  "Parted - ArchWiki"  |  https://wiki.archlinux.org/index.php/Parted
#
#   www.thegeekdiary.com  |  "How To Create a Partition Using “parted” Command – The Geek Diary"  |  https://www.thegeekdiary.com/how-to-create-a-partition-using-parted-command/
#
# ------------------------------------------------------------