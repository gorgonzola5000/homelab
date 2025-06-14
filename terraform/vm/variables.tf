variable "gateway_ip" {
  type    = string
  default = "10.2.137.1"
}

variable "domain" {
  type    = string
  default = "parents-basement.win"
}

data "cloudflare_zone" "domain" {
  name = var.domain
}

variable "dns_mappings" {
  description = <<EOT
Mapping of IPv4 addresses to domains and their CNAMEs.

Example configuration:
{
  "host-name" = {
    ipv4 = "192.168.1.1"
    cnames = ["www.xyz", "api.xyz"]
  }
}

Results in resources (for dev environment):
  host-name.dev.subdomain.example.com IN A 192.168.1.1
  www.host-name.dev.subdomain.example.com IN CNAME host-name.dev.subdomain.example.com
  api.host-name.dev.subdomain.example.com IN CNAME host-name.dev.subdomain.example.com
EOT

  type = map(object({
    ipv4    = string
    aliases = list(string)
  }))
}


variable "subdomain" {
  type    = string
  default = "home"
}

variable "environment" {
  type        = string
  description = "Environment name/DNS zone"
}

variable "vm_id_schema" {
  type        = number
  description = "eg. vm_id_schema = 2 --> vm_ids in this env are 2XX"
}
