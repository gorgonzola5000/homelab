data "cloudflare_zones" "homelab" {
  name = "parents-basement.win"
}

resource "cloudflare_dns_record" "homelab_cname" {
  content = "hkj0ah4db6f.sn.mynetname.net"
  name    = "pbvpn.home.${data.cloudflare_zones.homelab.name}"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  zone_id = data.cloudflare_zones.homelab.result[0].id
}
