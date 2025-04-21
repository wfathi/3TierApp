# Variables for the VM module
# This module creates a VM in Proxmox VE using a template and cloud-init for configuration.

variable "target_node" {
    type = string
    default = "proxmox"
    description = "Name of the target node in Proxmox"
}

variable "template_tag" {
  type = string
  default = "template"
  description = "Tag used to identify the template"
}

variable "vm_hostname" {
  type = string
  default = "gitlab"
}

variable "vm_domain" {
  type = string
  default = "local.com"
}

variable "on_boot" {
  type = bool
  default = true
  description = "Auto start the vm when the node starts"
}

variable "vm_tags" {
  type = list(string)
  default = ["dns"]
}

variable "vm_cpu_cores" {
  type = number
  default = 4
  description = "Number of CPU cores for the VM"
}

variable "vm_cpu_sockets" {
  type = number
  default = 1
  description = "Number of CPU sockets for the VM"
}

variable "vm_memory" {
  type = number
  description = "Memory size for the VM"
}

variable "vm_network_bridge" {
  type = string
  default = "vmbr0"
  description = "Network bridge for the VM"
}

variable "vm_disk" {
    type = object({
      storage = string
      size = number
    })
    default = {
      storage = "local-lvm"
      size = 20
    }
    description = "Disk configuration for the VM"
}

variable "vm_additional_disks" {
  type = list(object({
    storage = string
    size = number
  }))
  default = []
  description = "List of additional disks for the VM"
}

variable "vm_ip_address" {
  description = "The IP address of the VM"
  type = string
}

variable "vm_ip_gateway" {
  description = "The default gateway of the VM"
  type = string
}