resource "cloudflare_record" "a_OPNsense" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "opnsense.${var.subdomain}"
  value   = "10.2.137.1"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "a_proxmox" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "proxmox.${var.subdomain}"
  value   = "10.2.137.3"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "a_openWRT" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "openwrt.${var.subdomain}"
  value   = "10.2.137.2"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "cname_registry_gitlab" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "registry.gitlab.${var.subdomain}"
  value   = "gitlab.${var.subdomain}.${data.cloudflare_zone.domain.name}"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "a_gitlab" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "gitlab.${var.subdomain}"
  value   = "10.2.137.5"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "a_gitlab-runner" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "gitlab-runner.${var.subdomain}"
  value   = "10.2.137.6"
  type    = "A"
  ttl     = 3600
  proxied = false
}

data "cloudflare_zone" "domain" {
  name = "parents-basement.win"
}

variable "subdomain" {
  type    = string
  default = "home"
}
