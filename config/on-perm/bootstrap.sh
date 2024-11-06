#!/bin/bash
proxmox_ip = $(awk -F': ' '{print $2}' /vagrant/config.yaml)
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
$proxmox_ip proxmox.local proxmox
EOF
