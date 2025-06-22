variable "vm_config" {
  type = map(object({
    name      = string
    vm_id     = number
    ipv4      = string
    domain    = string
    subdomain = string
  }))
}

variable "gateway_ip" {}
variable "alma_qcow2_file_id" {}
variable "zone_id" {}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vm_config

  name        = each.value.name
  tags        = ["terraform", "alma"]
  description = "IdM"

  node_name = "proxmox"
  vm_id     = each.value.vm_id

  agent {
    enabled = true
  }
  stop_on_destroy = true

  memory {
    dedicated = 2560
  }

  cpu {
    cores = 1
    type  = "host"
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = var.alma_qcow2_file_id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${each.value.ipv4}/24"
        gateway = var.gateway_ip
      }
    }

    dns {
      servers = [var.gateway_ip]
      domain  = "${each.value.subdomain}.${each.value.domain}"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud-init[each.key].id
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_file" "cloud-init" {
  for_each = var.vm_config

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox"

  source_raw {
    data = <<-EOF
    #cloud-config
    allow_public_ssh_keys: true
    hostname: ${each.value.name}
    create_hostname_file: true
    fqdn: ${each.value.name}.${each.value.subdomain}.${each.value.domain}
    prefer_fqdn_over_hostname: true
    users:
      - name: ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups:
          - sudo
          - wheel
        shell: /bin/bash
        chpasswd: 
          expire: false
        ssh_authorized_keys:
          - ${var.ansible_public_key}
    runcmd:
        - yum update
        - yum install -y qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Warsaw
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "${each.value.name}-cloud-config.yaml"
  }
}

resource "cloudflare_record" "a_record" {
  for_each = var.vm_config

  zone_id = var.zone_id
  name    = "${each.value.name}.${each.value.subdomain}"
  value   = each.value.ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
}

variable "ansible_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYine9qQWjvBhbxoEP5OFz7bWzuMwUZVPR+7VgfZd1X"
}

