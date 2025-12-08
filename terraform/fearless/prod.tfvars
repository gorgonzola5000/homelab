proxmox_insecure          = true
proxmox_physical_host     = true
proxmox_hostname          = "fearless"
proxmox_ip                = "10.2.137.50"
gateway_ip                = "10.2.137.1"
talos_cluster_name        = "meddle"
talos_hostname            = "echoes"
talos_ip                  = "10.2.137.51"
talos_mac_address         = "F2:FA:CE:B0:0C:01"
talos_kubernetes_endpoint = "api.meddle.home.parents-basement.win"
talos_disk_wwids          = ["naa.5000cca028ca10bc", "naa.5000cca06d664258", "naa.5000cca028253590", "naa.5000cca028c9fecc"]
sops_age_key_path         = "../../sops/meddle/age.enc.yaml"
# 44 gibibytes
talos_ram = 45056

