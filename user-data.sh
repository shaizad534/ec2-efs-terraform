#!/bin/bash

sudo su - root
# Install AWS EFS Utilities
yum install -y amazon-efs-utils
# Mount EFS
efs_id="${efs_id}"
mount -t efs $efs_id:/ /home
# Edit fstab so EFS automatically loads on reboot
echo $efs_id:/ /home efs defaults,_netdev 0 0 >> /etc/fstab
