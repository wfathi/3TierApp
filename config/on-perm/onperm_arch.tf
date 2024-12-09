terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.68.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox-server01.test.com:8006/"
  api_token = "${var.proxmox_tf_user_token_id}=${var.proxmox_tf_user_token_value}"
  insecure = true
}

data "proxmox_virtual_environment_vms" "template" {
  node_name = var.target_node
  tags = [var.template_tag]
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  node_name = var.target_node
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = file("${path.module}/cloud-init/${var.vm_hostname}.${var.vm_domain}-ci-user-data.yml")
    file_name = "${var.vm_hostname}.${var.vm_domain}-ci-user-data.yml"
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
    sockets = var.cpu_sockets
    cores = var.cpu_cores
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
    }
  }

  boot_order = ["scsi0"]
  scsi_hardware = "virtio-scsi-single"

  clone {
    node_name = var.target_node
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id
  }

  initialization {
     user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = random_password.ubuntu_vm_password.result
      username = "devops"
    }
    datastore_id = "local"
    interface = "ide2"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }
}

resource "random_password" "ubuntu_vm_password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "vm_private_key" {
  value = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
  sensitive = true
}

output "vm_password" {
  value = random_password.ubuntu_vm_password.result
  sensitive = true
}