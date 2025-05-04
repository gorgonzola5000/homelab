vm_id_schema = 2
environment  = "dev"
is_prod      = false
dns_mappings = {
  "speak-to-me" = {
    ipv4    = "10.2.137.21"
    aliases = ["gotify", "homeassistant", "pihole", "glance"]
  }
  "breathe" = {
    ipv4    = "10.2.137.22"
    aliases = ["qbittorrent", "gluetun", "prowlarr", "sonarr", "radarr", "jellyseerr", "jellyfin", "lidarr"]
  }
}
media_disk_size = 50
