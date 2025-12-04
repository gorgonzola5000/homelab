module "talos-iso" {
  source = "../modules//talos-iso"

  hostname    = var.talos_hostname
  gateway     = var.gateway_ip
  static_ip   = var.talos_ip
  subnet_mask = "/24"
}

module "talos" {
  source = "../modules/talos"

  zfs_pool_passphrase = var.talos_zfs_pool_passphrase
  cluster_name        = var.talos_cluster_name
  hostname            = var.talos_hostname
  kubernetes_endpoint = var.talos_kubernetes_endpoint
  gateway             = var.gateway_ip
  mac_address         = var.talos_mac_address
  ip                  = var.talos_ip
  subnet_mask         = "/24"
  talos_installer_url = module.talos-iso.raw_image_url
  disk_wwids          = var.talos_disk_wwids

  depends_on = [proxmox_virtual_environment_vm.this]
}
