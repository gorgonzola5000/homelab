resource "proxmox_virtual_environment_vm" "this" {
  name        = "echoes"
  description = "Talos Linux"

  node_name = local.proxmox_hostname
  vm_id     = "666"

  agent {
    enabled = true
  }

  stop_on_destroy = true

  memory {
    dedicated = local.talos_ram
  }

  cpu {
    cores = 2
    type  = "host"
  }

  machine = "q35"

  disk {
    datastore_id = local.proxmox_datastore_id
    file_id      = proxmox_virtual_environment_download_file.this.id
    interface    = "scsi0"
    size         = 128
    file_format  = "raw"
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  dynamic "hostpci" {
    # If the variable is true, create a list with one item [1]. 
    # If false, create an empty list [].
    for_each = var.proxmox_physical_host ? [1] : []

    content {
      device = "hostpci0"
      mapping = proxmox_virtual_environment_hardware_mapping_pci.this[0].name
      rombar = true
      xvga   = false
      pcie   = true
    }
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.talos_ip}/24"
        gateway = local.proxmox_gateway_ip
      }
    }
    dns {
      servers = [local.proxmox_gateway_ip]
      domain  = local.proxmox_dns_search_domain
    }
    datastore_id = local.proxmox_datastore_id
  }

  network_device {
    bridge      = local.proxmox_bridge
    mac_address = local.talos_mac_address
  }

  lifecycle {
    ignore_changes = [
      initialization
    ]
  }
}

resource "proxmox_virtual_environment_hardware_mapping_pci" "this" {
  count = var.proxmox_physical_host ? 1 : 0

  name    = "HBA"
  comment = "Passthrough for the LSI HBA"

  map = [
    {
      node         = local.proxmox_hostname
      id           = "1000:0072"
      path         = "0000:01:00.0"
      iommu_group  = 2
      subsystem_id = "1000:3020"
    },
  ]

  mediated_devices = false
}

resource "proxmox_virtual_environment_download_file" "this" {
  node_name               = local.proxmox_hostname
  datastore_id            = local.proxmox_datastore_id
  content_type            = "iso"
  url                     = module.talos-iso.raw_image_url
  file_name               = "metal-amd64.raw.zst.img"
  overwrite_unmanaged     = true
  decompression_algorithm = "zst"
}
