locals {
  # stuff that I would prefer to specify in the provider block but I cannot
  proxmox_hostname          = var.proxmox_hostname
  proxmox_datastore_id      = "local"
  proxmox_bridge            = "vmbr0"
  proxmox_gateway_ip        = local.gateway_ip
  proxmox_dns_search_domain = local.homelab_domain
  proxmox_ip                = var.proxmox_ip

  talos_cluster_name        = var.talos_cluster_name
  talos_hostname            = var.talos_hostname
  talos_kubernetes_endpoint = "api.${local.talos_cluster_name}.${local.homelab_domain}"
  talos_mac_address         = var.talos_mac_address
  talos_ip                  = var.talos_ip
  talos_ram                 = 45056
  talos_kubernetes_version  = "1.35.0"
  talos_talos_version       = "1.12.1"

  homelab_domain = "home.${local.apex_domain}"
  apex_domain    = "parents-basement.win"
  gateway_ip     = var.gateway_ip
  subnet_mask    = "/24"
}
