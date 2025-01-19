vm_id_schema = 4
environment  = "test"
is_prod      = false
dns_mappings = {
  "alma" = {
    ipv4    = "10.2.137.42"
    aliases = ["homeassistant", "pihole", "glance", "prometheus", "grafana"]
  }
}
