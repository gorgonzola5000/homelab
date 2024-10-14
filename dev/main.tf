resource "proxmox_virtual_environment_vm" "debian_12_dev" {
  name        = "debian-12-dev"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian"]

  node_name = "pve"
  vm_id     = 221

  agent {
    enabled = true
  }
  stop_on_destroy = true

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/debian-vm-1.qcow2.iso"
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.2.137.8/24"
        gateway = "10.2.137.1"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
