variable "domain" {
  type    = string
  default = "parents-basement.win"
}

data "cloudflare_zone" "domain" {
  name = var.domain
}

variable "subdomain" {
  type    = string
  default = "home"
}

variable "gateway_ip" {
  type    = string
  default = "10.2.137.1"
}

variable "freeipa-ipv4" {
  type = string
  default = "10.2.137.2"
}
