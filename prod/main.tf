resource "proxmox_virtual_environment_vm" "alma_linux_9" {
  name        = "alma-linux-9"
  description = "Managed by Terraform"
  tags        = ["terraform", "alma"]

  node_name = "pve"
  vm_id     = 333

  agent {
    enabled = true
  }
  stop_on_destroy = true

  memory {
    dedicated = 4096
  }

  cpu {
    cores = 1
    type  = "host"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/alma-linux-9.qcow2.iso"
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

resource "proxmox_virtual_environment_vm" "gitlab" {
  name        = "gitlab"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian"]

  node_name = "pve"
  vm_id     = 334

  agent {
    enabled = true
  }
  stop_on_destroy = true

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/gitlab.qcow2.iso"
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.2.137.5/24"
        gateway = "10.2.137.1"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}

