vm_id_schema = 2
environment  = "dev"
is_prod      = false
dns_mappings = {
  "alma" = {
    ipv4    = "10.2.137.22"
    aliases = ["homeassistant", "pihole", "glance", "jellyfin", "sonarr", "qbittorrent", "jellyseerr"]
  }
}
media_disk_size = 20
