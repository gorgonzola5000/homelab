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
  value   = "10.2.137.1"
  type    = "A"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "cname_Home_Assistant" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "homeassistant.${var.subdomain}"
  value   = "alma.${var.subdomain}"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "a_alma" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "alma.${var.subdomain}"
  value   = "10.2.137.2"
  type    = "A"
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
