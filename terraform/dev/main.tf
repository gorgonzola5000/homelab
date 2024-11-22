variable "gateway_ip" {
  type    = string
  default = "10.2.137.1"
}

variable "domain" {
  type    = string
  default = "parents-basement.win"
}

variable "subdomain" {
  type    = string
  default = "home"
}

variable "environment" {
  type        = string
  description = "Environment name/DNS zone"
}

variable "vm_id_schema" {
  type        = number
  description = "eg. vm_id_schema = 2 --> vm_ids in this env are 2XX"
}

resource "proxmox_virtual_environment_vm" "alma_linux_9" {
  name        = "alma-linux-9-${var.environment}"
  tags        = ["terraform", "alma"]
  description = "VPN server, ddclient, pihole, dashboard"

  node_name = "pve"
  vm_id     = tonumber("${var.vm_id_schema}20")

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
    file_id      = "local:iso/alma-test.qcow2.iso"
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    dns {
      servers = [var.gateway_ip]
      domain  = "${var.environment}.${var.subdomain}.${var.domain}"
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
