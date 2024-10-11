resource "proxmox_virtual_environment_vm" "debian_12_homelab" {
  name        = "debian-12-homelab"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian"]

  node_name = "pve"
  vm_id     = 222

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
        address = "10.2.137.2/24"
        gateway = "10.2.137.1"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
