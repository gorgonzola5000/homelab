data "cloudflare_zones" "email" {
  name = "michalek.sh"
}

resource "cloudflare_dns_record" "icloud_mx01" {
  zone_id  = data.cloudflare_zones.email.result[0].id
  name     = "@"
  type     = "MX"
  content  = "mx01.mail.icloud.com."
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "icloud_mx02" {
  zone_id  = data.cloudflare_zones.email.result[0].id
  name     = "@"
  type     = "MX"
  content  = "mx02.mail.icloud.com."
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "icloud_spf" {
  zone_id = data.cloudflare_zones.email.result[0].id
  name    = "@"
  type    = "TXT"
  content = "v=spf1 include:icloud.com ~all"
  ttl     = 1
}

resource "cloudflare_dns_record" "apple_verification" {
  zone_id = data.cloudflare_zones.email.result[0].id
  name    = "@"
  type    = "TXT"
  content = "apple-domain=9xtipRfEgCtDFYLB"
  ttl     = 1
}

resource "cloudflare_dns_record" "icloud_dkim" {
  zone_id = data.cloudflare_zones.email.result[0].id
  name    = "sig1._domainkey"
  type    = "CNAME"
  content = "sig1.dkim.example.com.at.icloudmailadmin.com."
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "icloud_dmarc" {
  zone_id = data.cloudflare_zones.email.result[0].id
  name    = "_dmarc"
  type    = "TXT"
  content = "v=DMARC1; p=none;"
  ttl     = 1
}
