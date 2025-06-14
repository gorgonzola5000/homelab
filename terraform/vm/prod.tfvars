vm_id_schema = 1
environment  = "prod"
is_prod      = true
dns_mappings = {
  "speak-to-me" = {
    ipv4    = "10.2.137.11"
    aliases = ["gotify", "homeassistant", "pihole", "glance"]
  }
  "breathe" = {
    ipv4    = "10.2.137.12"
    aliases = ["qbittorrent", "gluetun", "prowlarr", "sonarr", "radarr", "jellyseerr", "jellyfin", "lidarr"]
  }
}
