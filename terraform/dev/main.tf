variable "gateway_ip" {
  type    = string
  default = "10.2.137.1"
}

variable "domain" {
  type    = string
  default = "parents-basement.win"
}

data "cloudflare_zone" "domain" {
  name = var.domain
}

variable "dns_mappings" {
  description = <<EOT
Mapping of IPv4 addresses to domains and their CNAMEs.

Example configuration:
{
  "host-name" = {
    ipv4 = "192.168.1.1"
    cnames = ["www.xyz", "api.xyz"]
  }
}

Results in resources (for dev environment):
  host-name.dev.subdomain.example.com IN A 192.168.1.1
  www.host-name.dev.subdomain.example.com IN CNAME host-name.dev.subdomain.example.com
  api.host-name.dev.subdomain.example.com IN CNAME host-name.dev.subdomain.example.com
EOT

  type = map(object({
    ipv4    = string
    aliases = list(string)
  }))
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
    file_id      = proxmox_virtual_environment_download_file.alma_9_qcow2.id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.dns_mappings.alma.ipv4}/24"
        gateway = var.gateway_ip
      }
    }
    dns {
      servers = [var.gateway_ip]
      domain  = "${var.environment}.${var.subdomain}.${var.domain}"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_yum.id
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "alma_9_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://repo.almalinux.org/almalinux/9.4/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
  file_name    = "${var.environment}-AlmaLinux-9-GenericCloud-9.4.x86_64.qcow2.iso"
}
