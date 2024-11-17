#!/bin/bash
set -e
# To suppress user prompts 
export DEBIAN_FRONTEND=noninteractive
proxmox_ip=$(awk -F'"' '/proxmox_ip/ {print $2}' /vagrant/config.yaml)
proxmox_gateway=$(awk -F'"' '/proxmox_gateway/ {print $2}' /vagrant/config.yaml)
password_proxmox_user=$(awk -F'"' '/password_proxmox_user/ {print $2}' /vagrant/config.yaml)
username_proxmox_user=$(awk -F'"' '/username_proxmox_user/ {print $2}' /vagrant/config.yaml)
proxmox_tf_user_token_expiration=$(awk -F'"' '/proxmox_token_expiration/ {print $2}' /vagrant/config.yaml)
proxmox_tf_user_token_path=$(awk -F'"' '/proxmox_tf_user_token_path/ {print $2}' /vagrant/config.yaml)
echo "Detected Proxmox IP: $proxmox_ip"

cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
$proxmox_ip proxmox.local proxmox
EOF

cat > /etc/network/interfaces << EOF
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp  
    dns-nameserver 8.8.8.8
    dns-nameserver 4.2.2.1
    dns-nameserver 4.2.2.2
    pre-up sleep 2

iface eth1 inet manual

auto vmbr0
iface vmbr0 inet static
    address $proxmox_ip/24
    gateway $proxmox_gateway
    bridge-ports eth1
    bridge-stp off
    bridge-fd 0
EOF

echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg

# Help prevent interactive prompts from the installation of GRUB by specifying in which disk to install the GRUB
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | sudo debconf-set-selections

apt update -y && apt full-upgrade -y

apt install -y proxmox-ve ksm-control-daemon locales-all chrony libguestfs-tools

apt remove linux-image-amd64 'linux-image-6.1*' os-prober -y

update-grub
# Terraform Role to create and manage VMs inside of the proxmox for security reasons
sudo pveum role add TerraformProv -privs "Datastore.Allocate Datastore.AllocateSpace \
 Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit \
 VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk \ 
 VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console\
 VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
# Terraform user
sudo pveum user add $username_proxmox_user --password $password_proxmox_user
# Attach the Terraform role to the user
sudo pveum aclmod / -user $username_proxmox_user -role TerraformProv
# Create a token for the user
sudo pveum user token add $username_proxmox_user terraform -expire $proxmox_token_expiration -privsep 0 -comment "Terraform token" > $proxmox_tf_user_token_path