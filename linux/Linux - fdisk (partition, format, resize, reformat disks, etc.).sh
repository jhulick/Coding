#!/bin/bash

fdisk /dev/sdb

# Type 'n' > Enter

# fdisk's built-in wizard will walk you creating a partition

# Type 'w' > Enter to save changes at the end

parted dev/sdb1






# ------------------------------------------------------------
#
# Citation(s)
#
#   devconnected.com  |  "How To Create Disk Partitions on Linux – devconnected"  |  https://devconnected.com/how-to-create-disk-partitions-on-linux/
#
#   www.cyberciti.biz  |  "How To Install EPEL Repo on a CentOS and RHEL 7.x - nixCraft"  |  https://www.cyberciti.biz/faq/installing-rhel-epel-repo-on-centos-redhat-7-x/
#
# ------------------------------------------------------------