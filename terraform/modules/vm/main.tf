resource "proxmox_vm_qemu" "vm" {
  name        = var.name
  target_node = var.target_node
  clone       = var.template_name
  
  cores   = var.cores
  memory  = var.memory
  sockets = var.sockets
  
  network {
    model  = "virtio"
    bridge = var.network_bridge
  }
  
  disk {
    storage = var.storage
    size    = var.disk_size
    type    = "scsi"
  }
  
  ipconfig0 = "ip=${var.ip_address}/24,gw=${var.gateway}"
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
