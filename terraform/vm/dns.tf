variable "is_prod" {
  type    = bool
  default = false
}

# this creates CNAME records if it is production environment like this:
# NAME                                TYPE    VALUE 
# some-service.whatever.example.com   CNAME   some-service.prod.whatever.example.com
resource "cloudflare_record" "dns_cname_to_prod" {
  for_each = {
    for index, cname_mapping in flatten([
      for canonical, mapping in var.dns_mappings : [
        for alias in mapping.aliases : {
          name  = "${alias}.${var.subdomain}"
          value = "${canonical}.${var.environment}.${var.subdomain}.${data.cloudflare_zone.domain.name}"
        }
      ]
    ]) : cname_mapping.name => cname_mapping
    if var.is_prod == true
  }
  name  = each.value.name
  value = each.value.value

  zone_id = data.cloudflare_zone.domain.id
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

# this creates A records like this:
# NAME                                TYPE    VALUE 
# some-host.whatever.example.com      A       192.168.1.1
resource "cloudflare_record" "dns_a_records" {
  for_each = var.dns_mappings

  zone_id = data.cloudflare_zone.domain.id
  name    = "${each.key}.${var.environment}.${var.subdomain}"
  value   = each.value.ipv4
  type    = "A"
  ttl     = 3600
  proxied = false
}

# this creates CNAME records like this:
# NAME                                    TYPE    VALUE 
# some-service.dev.whatever.example.com   CNAME   some-host.dev.whatever.example.com
resource "cloudflare_record" "dns_cname_records" {
  for_each = {
    for index, cname_mapping in flatten([
      for canonical, mapping in var.dns_mappings : [
        for alias in mapping.aliases : {
          name  = "${alias}.${var.environment}.${var.subdomain}"
          value = "${canonical}.${var.environment}.${var.subdomain}.${data.cloudflare_zone.domain.name}"
        }
      ]
    ]) : cname_mapping.name => cname_mapping
  }
  name  = each.value.name
  value = each.value.value

  zone_id = data.cloudflare_zone.domain.id
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}
