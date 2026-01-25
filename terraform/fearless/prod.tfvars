proxmox_insecure          = true
proxmox_physical_host     = true
proxmox_hostname          = "fearless"
proxmox_ip                = "10.2.137.50"
gateway_ip                = "10.2.137.1"
talos_cluster_name        = "meddle"
talos_hostname            = "echoes"
talos_ip                  = "10.2.137.51"
talos_mac_address         = "f2:fa:ce:b0:0c:01"
talos_kubernetes_endpoint = "api.meddle.home.parents-basement.win"
talos_disk_wwids = [
  "naa.5000cca028ca10bc",
  "naa.5000cca06d25f8e8",
  "naa.5000cca06d664258",
  "naa.5000cca0282cdfb4",
  "naa.5000cca028253590",
  "naa.5000cca028cad8e8",
  "naa.5000cca028c9fecc",
  "naa.5000cca06d22747c",
  "naa.5000cca0289af74c",
  "naa.5000cca0289aa3a0",
  "naa.5000cca028cbe2ac",
  "naa.5000cca0288aa9e4",
]
flux_sops_age_key_path = "../../sops/meddle/flux-secret.enc.yaml"
# 44 gibibytes
talos_ram = 45056

