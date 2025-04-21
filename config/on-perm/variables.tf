variable "proxmox_tf_user_token_value" {
    description = "Token value to connect Proxmox API"
    type = string
}

variable "user_dir" {
  description = "The user directory"
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

variable "vm_cicd_template_tag" {
  type = string
  default = "template"
  description = "Tag used to identify the template"
}

variable "vm_dns_template_tag" {
  type = string
  default = "template"
  description = "Tag used to identify the template"
}

variable "vm_cicd_hostname" {
  type = string
  default = "gitlab"
}

variable "vm_dns_hostname" {
  type = string
  default = "dns"
}

variable "vm_cicd_domain" {
  type = string
  default = "local.com"
}

variable "vm_dns_domain" {
  type = string
  default = "local.com"
}

variable "on_boot" {
  type = bool
  default = true
  description = "Auto start the vm when the node starts"
}

variable "vm_cicd_tags" {
  type = list(string)
  default = ["cicd"]
}

variable "vm_dns_tags" {
  type = list(string)
  default = ["dns"]
}

variable "vm_cicd_cpu_cores" {
  type = number
  default = 4
  description = "Number of CPU cores for the CICD VM"
}

variable "vm_dns_cpu_cores" {
  type = number
  default = 1
  description = "Number of CPU cores for DNS the VM"
}

variable "vm_cicd_cpu_sockets" {
  type = number
  default = 1
  description = "Number of CPU sockets for the CICD VM"
}

variable "vm_dns_cpu_sockets" {
  type = number
  default = 1
  description = "Number of CPU sockets for the DNS VM"
}

variable "vm_cicd_memory" {
  type = number
  default = 5120
  description = "Memory size for the VM"
}

variable "vm_dns_memory" {
  type = number
  default = 1024
  description = "Memory size for the VM"
}

variable "vm_network_bridge" {
  type = string
  default = "vmbr0"
  description = "Network bridge for the VM"
}

variable "vm_cicd_disk" {
    type = object({
      storage = string
      size = number
    })
    default = {
      storage = "local-lvm"
      size = 30
    }
    description = "Disk configuration for the CICD VM"
}

variable "vm_dns_disk" {
    type = object({
      storage = string
      size = number
    })
    default = {
      storage = "local-lvm"
      size = 10
    }
    description = "Disk configuration for the DNS VM"
}

variable "vm_cicd_additional_disks" {
  type = list(object({
    storage = string
    size = number
  }))
  default = []
  description = "List of additional disks for the CICD VM"
}

variable "vm_dns_additional_disks" {
  type = list(object({
    storage = string
    size = number
  }))
  default = []
  description = "List of additional disks for the DNS VM"
}

variable "vm_cicd_ip_address" {
  description = "The IP address of the CICD VM"
  type = string
}

variable "vm_cicd_ip_gateway" {
  description = "The default gateway of the CICD VM"
  type = string
}

variable "vm_dns_ip_address" {
  description = "The IP address of the DNS VM"
  type = string
}

variable "vm_dns_ip_gateway" {
  description = "The default gateway of the DNS VM"
  type = string
}