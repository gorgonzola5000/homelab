resource "proxmox_virtual_environment_vm" "gitlab" {
  name        = "gitlab"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian"]

  node_name = "proxmox"
  vm_id     = 334

  agent {
    enabled = true
  }
  stop_on_destroy = true

  cpu {
    cores = 1
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/gitlab.qcow2.iso"
    interface    = "virtio0"
    size         = 50
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

resource "proxmox_virtual_environment_vm" "gitlab-runner" {
  name        = "gitlab-runner"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian"]

  node_name = "proxmox"
  vm_id     = 335

  agent {
    enabled = true
  }
  stop_on_destroy = true

  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/gitlab-runner.qcow2.iso"
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.2.137.6/24"
        gateway = "10.2.137.1"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
