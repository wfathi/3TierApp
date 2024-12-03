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
    bridge-ports eth1
    bridge-stp off
    bridge-fd 0
EOF

sudo timedatectl set-timezone $proxmox_time_zone

echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg

# Help prevent interactive prompts from the installation of GRUB by specifying in which disk to install the GRUB
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | sudo debconf-set-selections

apt update -y && apt full-upgrade -y

apt install -y proxmox-ve ksm-control-daemon locales-all chrony libguestfs-tools

apt remove linux-image-amd64 'linux-image-6.1*' os-prober -y

update-grub