cd /var/lib/vz/template/iso
vm_id=100
#sudo wget https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.img
sudo virt-customize -a ubuntu-20.04-server-cloudimg-amd64.img --install qemu-guest-agent
sudo qm create $vm_id --name "ubuntu.local" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
sudo qm importdisk $vm_id ubuntu-20.04-server-cloudimg-amd64.img local
sudo qm set $vm_id --scsihw virtio-scsi-pci --scsi0 local:$vm_id/vm-$vm_id-disk-0.raw
sudo qm set $vm_id --boot c --bootdisk scsi0
sudo qm set $vm_id --ide2 local:cloudinit

sudo apt install -y whois
passwd=`mkpasswd --method=SHA-512 $proxmox_ubuntu_template_passwd`
# I'm using cloud init so that the VM settings does not match the template settings (IP conflicts, etc..)
sudo tee /var/lib/vz/snippets/cloudinit_config.yaml > /dev/null <<EOF 
#cloud-config

## System Information
hostname: ubuntu_vm_proxmox
timezone: $proxmox_time_zone

users:
  - name: devopsEng
    sudo: ['ALL=(ALL)']
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: $passwd

network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true

package_update: true
package_upgrade: true
packages:
  - curl
  - git
  - openjdk-11-jdk
  - maven
  - python3-pip
  - jq
EOF

sudo qm set $vm_id --agent enabled=1
sudo qm set $vm_id --serial0 socket --vga serial0
sudo qm set $vm_id -cicustom user=local:snippets/cloudinit_config.yaml
sudo qm template $vm_id