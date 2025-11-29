data "cloudflare_zones" "this" {
  name = local.apex_domain
}

resource "cloudflare_dns_record" "a_proxmox" {
  zone_id = data.cloudflare_zones.this.result[0].id
  name    = "${local.proxmox_hostname}.${local.homelab_domain}"
  content = local.proxmox_ip
  type    = "A"
  ttl     = 7200
  proxied = false
}

resource "cloudflare_dns_record" "a_talos" {
  zone_id = data.cloudflare_zones.this.result[0].id
  name    = "${local.talos_hostname}.${local.homelab_domain}"
  content = local.talos_ip
  type    = "A"
  ttl     = 7200
  proxied = false
}

resource "cloudflare_dns_record" "cname_talos_cluster_api" {
  zone_id = data.cloudflare_zones.this.result[0].id
  name    = local.talos_kubernetes_endpoint
  content = "${local.talos_hostname}.${local.homelab_domain}"
  type    = "CNAME"
  ttl     = 7200
  proxied = false
}
