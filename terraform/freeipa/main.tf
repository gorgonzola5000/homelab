resource "proxmox_virtual_environment_vm" "freeipa" {
  name        = "freeipa"
  tags        = ["terraform", "alma"]
  description = "freeipa, keycloak"

  node_name = "proxmox"
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
    file_id      = proxmox_virtual_environment_download_file.alma_9_qcow2.id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.freeipa-ipv4}/24"
        gateway = var.gateway_ip
      }
    }
    dns {
      servers = [var.gateway_ip]
      domain  = "${var.subdomain}.${var.domain}"
    }

    user_data_file_id = proxmox_virtual_environment_file.freeipa_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "alma_9_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://repo.almalinux.org/almalinux/9.4/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
  file_name    = "freeipa-AlmaLinux-9-GenericCloud-9.4.x86_64.qcow2.iso"
}

resource "cloudflare_record" "a_freeipa" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "freeipa.${var.subdomain}"
  value   = var.freeipa-ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
}
