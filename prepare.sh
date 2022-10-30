#!/bin/bash
#
# Title: Ubuntu Template
#
# Author: Bitfinity / L. Rutten
# Owner: Bitfinity / L. Rutten
#
# File: prepare-ubuntu.sh
#
# Description:
#   This bash script contains the steps to 
#   prepare Ubuntu for a (ProxmoxVE) Template.
#
# source(s):
#   - https://www.burgundywall.com/post/using-cloud-init-to-set-static-ips-in-ubuntu-20-04
#

# Update and upgrade system
apt update && apt -y upgrade && apt -y autoremove && apt clean


# Clear OpenSSH hostkeys
sudo rm ssh_host_*

# Clear hostname
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost

# Clear Machine-ID
truncate -s0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# this prevents network configuration from happening, says so right in the name
rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg

# ConfigDrive needs to come first (I think)
cat << EOF > /etc/cloud/cloud.cfg.d/99-pve.cfg
datasource_list: [ConfigDrive, NoCloud]
EOF

# this is super important, netplan files are not regenerated if they exist
mv /etc/netplan/00-installer-config.yaml /etc/netplan/01-netcfg.yaml
#rm -f /etc/netplan/00-installer-config.yaml
#rm -f /etc/netplan/50-cloud-init.yaml


# Clean Cloudinit
cloud-init clean

# Remove Root password (if is set)
passwd -dl root

# Clear shell history
truncate -s0 ~/.bash_history
history -c

# Clean the template
sudo apt clean
sudo apt autoremove

# Shutdown system
shutdown -h now
