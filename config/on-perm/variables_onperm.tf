variable "proxmox_tf_user_token_value" {
    description = "Token value to connect Proxmox API"
    type = string
}

variable "proxmox_tf_user_token_id" {
    description = "Token ID to connect Proxmox API"
    type = string
}

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
  default = "vm_cicd"
}

variable "vm_domain" {
  type = string
  default = "fth.local"
}

variable "on_boot" {
  type = bool
  default = true
  description = "Auto start the vm when the node starts"
}

variable "vm_tags" {
  type = list(string)
  default = ["c_cd"]
}

variable "cpu_cores" {
  type = number
  default = 1
  description = "Number of CPU cores for the VM"
}

variable "cpu_sockets" {
  type = number
  default = 1
  description = "Number of CPU sockets for the VM"
}

variable "vm_memory" {
  type = number
  default = 2048
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
      storage = "local"
      size = 10
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