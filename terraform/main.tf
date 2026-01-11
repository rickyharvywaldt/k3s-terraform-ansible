# This is a Terraform configuration to provision a k3s cluster on Proxmox
# and generate an Ansible inventory for k3s-ansible deployment.
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.80.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
}

# Bastion node
resource "proxmox_virtual_environment_vm" "k3s_bastion" {
  count = var.enable_bastion ? 1 : 0
  
  name      = "k3s-bastion"
  node_name = var.proxmox_node
  vm_id     = 199
  
  clone {
    vm_id = var.template_vm_id
    full  = true
  }
  
  cpu {
    cores = var.bastion_cores
  }
  
  memory {
    dedicated = var.bastion_memory
  }
  
  network_device {
    bridge = "vmbr0"
  }
  
  agent {
    enabled = false
  }
  
  initialization {
    ip_config {
      ipv4 {
        address = var.bastion_ip
        gateway = var.gateway
      }
    }
    user_account {
      username = var.ssh_user
      keys     = [var.ssh_public_key]
    }
  }
}

# Control plane nodes
resource "proxmox_virtual_environment_vm" "k3s_master" {
  count     = var.master_count
  name      = "k3s-cp${count.index + 1}"
  node_name = var.proxmox_node
  vm_id     = 200 + count.index

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  cpu {
    cores = var.master_cpu_cores
  }

  memory {
    dedicated = var.master_memory
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = false
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.master_ips[count.index]
        gateway = var.gateway
      }
    }
    user_account {
      username = var.ssh_user
      keys     = [var.ssh_public_key]
    }
  }
}

# Worker nodes
resource "proxmox_virtual_environment_vm" "k3s_worker" {
  count     = var.worker_count
  name      = "k3s-worker${count.index + 1}"
  node_name = var.proxmox_node
  vm_id     = 210 + count.index

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  cpu {
    cores = var.worker_cpu_cores
  }

  memory {
    dedicated = var.worker_memory
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = false
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.worker_ips[count.index]
        gateway = var.gateway
      }
    }
    user_account {
      username = var.ssh_user
      keys     = [var.ssh_public_key]
    }
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    masters = [for idx, vm in proxmox_virtual_environment_vm.k3s_master : {
      name = vm.name
      ip   = split("/", var.master_ips[idx])[0]
    }]
    workers = [for idx, vm in proxmox_virtual_environment_vm.k3s_worker : {
      name = vm.name
      ip   = split("/", var.worker_ips[idx])[0]
    }]
    bastion = var.enable_bastion ? {
      name = proxmox_virtual_environment_vm.k3s_bastion[0].name
      ip   = split("/", var.bastion_ip)[0]
    } : null
    enable_bastion  = var.enable_bastion
    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private_key_path
  })
  filename = "${path.module}/inventory/hosts.ini"

  depends_on = [
    proxmox_virtual_environment_vm.k3s_master,
    proxmox_virtual_environment_vm.k3s_worker,
    proxmox_virtual_environment_vm.k3s_bastion
  ]
}

# Output the inventory path
output "ansible_inventory_path" {
  value = local_file.ansible_inventory.filename
}

output "k3s_master_ip" {
  value = split("/", var.master_ips[0])[0]
}
