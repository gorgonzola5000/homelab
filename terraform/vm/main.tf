resource "proxmox_virtual_environment_vm" "speak-to-me" {
  name        = "speak-to-me-${var.environment}"
  tags        = ["terraform", "alma"]
  description = "VPN server, ddclient, pihole, dashboard"

  node_name = "proxmox"
  vm_id     = tonumber("${var.vm_id_schema}21")

  agent {
    enabled = true
  }
  stop_on_destroy = true

  memory {
    dedicated = 4096
  }

  cpu {
    cores = 2
    type  = "host"
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.alma_10_qcow2.id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.dns_mappings.speak-to-me.ipv4}/24"
        gateway = var.gateway_ip
      }
    }
    dns {
      servers = [var.gateway_ip]
      domain  = "${var.environment}.${var.subdomain}.${var.domain}"
    }

    datastore_id = "local-zfs"

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_yum.id
  }

  network_device {
    bridge = "vmbr0"
  }

  protection = var.is_prod
  on_boot    = var.is_prod

  lifecycle {
    ignore_changes = [
      initialization
    ]
  }
}

resource "proxmox_virtual_environment_vm" "breathe" {
  name        = "breathe-${var.environment}"
  tags        = ["terraform", "alma"]
  description = "qbittorrent, gluetun, prowlarr, sonarr, radarr, jellyseerr, jellyfin"

  node_name = "proxmox"
  vm_id     = tonumber("${var.vm_id_schema}22")

  agent {
    enabled = true
  }
  stop_on_destroy = true

  memory {
    dedicated = 4096
  }

  cpu {
    cores = 4
    type  = "host"
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.alma_10_qcow2.id
    size         = 64
    interface    = "virtio0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.dns_mappings.breathe.ipv4}/24"
        gateway = var.gateway_ip
      }
    }
    dns {
      servers = [var.gateway_ip]
      domain  = "${var.environment}.${var.subdomain}.${var.domain}"
    }

    datastore_id = "local-zfs"

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_yum.id
  }

  network_device {
    bridge = "vmbr0"
  }

  protection = var.is_prod
  on_boot    = var.is_prod

  lifecycle {
    ignore_changes = [
      initialization
    ]
  }
}

resource "proxmox_virtual_environment_download_file" "alma_10_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-10.0-20250528.0.x86_64.qcow2"
  file_name    = "${var.environment}-AlmaLinux-10-GenericCloud.x86_64.qcow2.iso"
}
