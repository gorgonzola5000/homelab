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
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.alma_9_qcow2.id
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

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_yum.id
  }

  network_device {
    bridge = "vmbr0"
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
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.alma_9_qcow2.id
    interface    = "virtio0"
    size         = 20
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio1"
    backup       = false
    file_format  = "raw"
    size         = var.media_disk_size
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

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_yum.id
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "alma_9_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
  file_name    = "${var.environment}-AlmaLinux-9-GenericCloud.x86_64.qcow2.iso"
}