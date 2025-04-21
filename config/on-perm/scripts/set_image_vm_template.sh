cd /var/lib/vz/template/iso
vm_id=100
sudo wget https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.img
sudo virt-customize -a ubuntu-20.04-server-cloudimg-amd64.img --install qemu-guest-agent
sudo qm create $vm_id --name "ubuntu.local" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
sudo qm importdisk $vm_id ubuntu-20.04-server-cloudimg-amd64.img local
sudo qm set $vm_id --tags "template"
sudo qm set $vm_id --scsihw virtio-scsi-pci --scsi0 local:$vm_id/vm-$vm_id-disk-0.raw
sudo qm set $vm_id --boot c --bootdisk scsi0
sudo qm set $vm_id --ide2 local:cloudinit

sudo qm set $vm_id --agent enabled=1
sudo qm set $vm_id --serial0 socket --vga serial0
sudo qm template $vm_id