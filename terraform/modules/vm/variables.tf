variable "name" {
  description = "VM name"
  type        = string
}

variable "target_node" {
  description = "Proxmox node"
  type        = string
}

variable "template_name" {
  description = "Template to clone from"
  type        = string
}

variable "cores" {
  description = "CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "sockets" {
  description = "CPU sockets"
  type        = number
  default     = 1
}

variable "storage" {
  description = "Storage location"
  type        = string
}

variable "disk_size" {
  description = "Disk size"
  type        = string
  default     = "20G"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "ip_address" {
  description = "IP address"
  type        = string
}

variable "gateway" {
  description = "Gateway IP"
  type        = string
}
