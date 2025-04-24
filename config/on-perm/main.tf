terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.69.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox.local:8006/"
  api_token = "${var.proxmox_tf_user_token_id}=${var.proxmox_tf_user_token_value}"
  
  ssh {
    username = "proxmox"
    agent = true
  }
}

module "dns_vm" {
  source = "./modules/vm"
  target_node = var.target_node
  template_tag = var.vm_dns_template_tag
  vm_hostname = var.vm_dns_hostname
  vm_domain = var.vm_dns_domain
  on_boot = var.on_boot
  vm_tags = var.vm_dns_tags
  vm_cpu_cores = var.vm_dns_cpu_cores
  vm_cpu_sockets = var.vm_dns_cpu_sockets
  vm_memory = var.vm_dns_memory
  vm_network_bridge = var.vm_network_bridge
  vm_disk = var.vm_dns_disk
  vm_additional_disks = var.vm_dns_additional_disks
  vm_ip_address = var.vm_dns_ip_address
  vm_ip_gateway = var.vm_dns_ip_gateway
  vm_dns_ip_address = var.vm_dns_ip_address
}

module "cicd_vm" {
  source = "./modules/vm"
  target_node = var.target_node
  template_tag = var.vm_cicd_template_tag
  vm_hostname = var.vm_cicd_hostname
  vm_domain = var.vm_cicd_domain
  on_boot = var.on_boot
  vm_tags = var.vm_cicd_tags
  vm_cpu_cores = var.vm_cicd_cpu_cores
  vm_cpu_sockets = var.vm_cicd_cpu_sockets
  vm_memory = var.vm_cicd_memory
  vm_network_bridge = var.vm_network_bridge
  vm_disk = var.vm_cicd_disk
  vm_additional_disks = var.vm_cicd_additional_disks
  vm_ip_address = var.vm_cicd_ip_address
  vm_ip_gateway = var.vm_cicd_ip_gateway
  vm_dns_ip_address = var.vm_dns_ip_address
}