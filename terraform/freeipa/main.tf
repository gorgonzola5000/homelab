module "vms" {
  source = "./modules/vm"

  gateway_ip = var.gateway_ip
  alma_qcow2_file_id = proxmox_virtual_environment_download_file.alma_10_qcow2.id
  zone_id            = data.cloudflare_zone.domain.id

  vm_config = {
    vm1 = {
      name      = "money"
      vm_id     = 336
      ipv4      = "10.2.137.36"
      domain    = var.domain
      subdomain = var.subdomain
    }
    vm2 = {
      name      = "us-and-them"
      vm_id     = 337
      ipv4      = "10.2.137.37"
      domain    = var.domain
      subdomain = var.subdomain
    }
    vm3 = {
      name      = "any-colour-you-like"
      vm_id     = 338
      ipv4      = "10.2.137.38"
      domain    = var.domain
      subdomain = var.subdomain
    }
  }
}

resource "proxmox_virtual_environment_download_file" "alma_10_qcow2" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-10.0-20250528.0.x86_64.qcow2"
  file_name    = "AlmaLinux-10-GenericCloud.x86_64.qcow2.iso"
}

resource "cloudflare_record" "srv_ldap" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "_ldap._tcp.${var.subdomain}"
  type    = "SRV"

  data {
    service  = "_ldap"
    proto    = "_tcp"
    name     = "money"
    priority = 0
    weight   = 0
    port     = 389
    target   = "money.${var.subdomain}.${var.domain}"
  }
}

resource "cloudflare_record" "cname_freeipa" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "freeipa.${var.subdomain}"
  value   = "money.${var.subdomain}.${data.cloudflare_zone.domain.name}"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}
