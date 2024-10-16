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

resource "proxmox_virtual_environment_vm" "alma_9_dev" {
  name        = "alma-9-dev"
  description = "Managed by Terraform"
  tags        = ["terraform", "alma"]

  node_name = "pve"
  vm_id     = 220

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
    file_id      = "local:iso/AlmaLinux-9-GenericCloud-9.4-20240507.x86_64.qcow2.iso"
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.2.137.9/24"
        gateway = "10.2.137.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }
}

data "local_file" "ssh_public_key" {
  filename = "/home/gorgonzola5000/.ssh/id_ed25519.pub"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    disable_root: false
    users:
      - name: root
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
      - name: gorgonzola5000
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - yum update
        - yum install -y qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Warsaw
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}

#resource "proxmox_virtual_environment_download_file" "alma_9_qcow2" {
#  content_type = "iso"
#  datastore_id = "local"
#  node_name    = "pve"
#  url          = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.4-20240507.x86_64.qcow2"
#  file_name    = "alma9-4.qcow2.iso"
#}
