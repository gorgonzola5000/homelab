vm_id_schema = 1
environment  = "prod"
is_prod      = true
dns_mappings = {
  "alma" = {
    ipv4    = "10.2.137.2"
    aliases = ["pihole", "glance", "prometheus", "grafana"]
  }
}
