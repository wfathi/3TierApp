# This module creates a VM in Proxmox VE using a template and cloud-init for configuration.

data "proxmox_virtual_environment_vms" "template" {
  node_name = var.target_node
  tags = [var.template_tag]
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  node_name = var.target_node
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = file("${path.module}/../../cloud-init/${var.vm_hostname}.${var.vm_domain}-ci-user-data.yaml")
    file_name = "${var.vm_hostname}.${var.vm_domain}-ci-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name = "${var.vm_hostname}.${var.vm_domain}"
  node_name = var.target_node
  on_boot = var.on_boot
  tags = var.vm_tags

  agent {
    # Already added Qemu guest agent them the template
    enabled = true
  }

  cpu {
    sockets = var.vm_cpu_sockets
    cores = var.vm_cpu_cores
    type =  "x86-64-v2-AES"
  }

  memory {
    dedicated = var.vm_memory
  }

  network_device {
    bridge = var.vm_network_bridge
    model = "virtio"
  }

  disk {
    iothread = true
    datastore_id = var.vm_disk.storage
    interface = "scsi0"
    size = var.vm_disk.size
    discard = "ignore"
  }

  dynamic "disk" {
    for_each = var.vm_additional_disks
    content {
      iothread = true
      datastore_id = disk.value.storage
      interface = "scsi${1 + disk.key}"
      size = disk.value.size
      discard = "ignore"
      file_format = "raw"
    }
  }

  boot_order = ["scsi0"]
  scsi_hardware = "virtio-scsi-single"

  clone {
    node_name = var.target_node
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
  }

  keyboard_layout = "fr"
  initialization {
    ip_config {
      ipv4 {
        address = "${var.vm_ip_address}"
        gateway = "${var.vm_ip_gateway}"
      } 
    }
    dns {
      servers = [ split("/","${var.vm_dns_ip_address}")[0], "8.8.8.8" ]
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }
}