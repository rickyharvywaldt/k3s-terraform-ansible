variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve1"
}

variable "template_vm_id" {
  description = "Template VM ID to clone from"
  type        = number
  default     = 100
}

variable "master_count" {
  description = "Number of k3s master nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of k3s worker nodes"
  type        = number
  default     = 2
}

variable "master_cpu_cores" {
  description = "CPU cores for master nodes"
  type        = number
  default     = 2
}

variable "master_memory" {
  description = "Memory in MB for master nodes"
  type        = number
  default     = 4096
}

variable "worker_cpu_cores" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
  default     = 4096
}

variable "master_ips" {
  description = "Static IPs for master nodes (CIDR format)"
  type        = list(string)
  default     = ["10.100.2.50/24"]
}

variable "worker_ips" {
  description = "Static IPs for worker nodes (CIDR format)"
  type        = list(string)
  default     = ["10.100.2.51/24", "10.100.2.52/24"]
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "10.100.2.1"
}

variable "ssh_user" {
  description = "SSH username for VMs"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/k3s-terraform-ansible"
}
