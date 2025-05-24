# This module creates a VM in Proxmox VE using a template and cloud-init for configuration.

data "proxmox_virtual_environment_vms" "template" {
  node_name = var.target_node
  tags = [var.template_tag]
}

locals {
  smtp_server_relay_config_file = var.vm_tags[0] == "cicd" ? file("${path.module}/../../smtp_server_relay_config.key") : null
  
  smtp_config_parsed = var.vm_tags[0] == "cicd" ? {
      smtp_address     = trimspace(regex("smtp_address=(.*)", local.smtp_server_relay_config_file)[0])
      smtp_port        = trimspace(regex("smtp_port=(.*)", local.smtp_server_relay_config_file)[0])
      smtp_user_name   = trimspace(regex("smtp_api_key=(.*)", local.smtp_server_relay_config_file)[0])
      smtp_password    = trimspace(regex("smtp_secret_key=(.*)", local.smtp_server_relay_config_file)[0])
  } : null

  cloud_init_cicd_template_file = var.vm_tags[0] == "cicd" ? templatefile(
    "${path.module}/../../cloud-init/${var.vm_hostname}.${var.vm_domain}-ci-user-data.yaml",
    {
      smtp_address = local.smtp_config_parsed.smtp_address
      smtp_port = local.smtp_config_parsed.smtp_port
      smtp_user_name = local.smtp_config_parsed.smtp_user_name
      smtp_password = local.smtp_config_parsed.smtp_password
      smtp_domain = var.vm_domain
      gitlab_email_from = "${var.vm_hostname}@${var.vm_domain}"
      gitlab_email_reply_to = "noreply-${var.vm_hostname}@${var.vm_domain}"
      gitlab_email_display_name = "${var.vm_hostname} ${var.vm_domain}"
      vm_dns_ip_address = split("/","${var.vm_dns_ip_address}")[0]
    }
  ) : null
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  node_name = var.target_node
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    # data = file("${path.module}/../../cloud-init/${var.vm_hostname}.${var.vm_domain}-ci-user-data.yaml")
    data = local.cloud_init_cicd_template_file != null ? local.cloud_init_cicd_template_file : file("${path.module}/../../cloud-init/${var.vm_hostname}.${var.vm_domain}-ci-user-data.yaml")
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
      servers = var.vm_tags[0] == "dns" ? [ split("/","${var.vm_dns_ip_address}")[0], "8.8.8.8", "8.8.4.4" ] : [ split("/","${var.vm_dns_ip_address}")[0] ]
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }
}