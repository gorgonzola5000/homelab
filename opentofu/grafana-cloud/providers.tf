terraform {
  backend "http" {}
  encryption {
    key_provider "pbkdf2" "this" {
      passphrase = var.state_passphrase
    }
    method "aes_gcm" "this" {
      keys = key_provider.pbkdf2.this
    }
    state {
      method   = method.aes_gcm.this
      enforced = true
    }
    plan {
      method   = method.aes_gcm.this
      enforced = true
    }
  }
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.36.2"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.4.1"
    }
  }
}

provider "sops" {}

data "sops_file" "grafana_secrets" {
  source_file = "../../sops/opentofu-secrets/secrets.enc.yaml"
}

provider "grafana" {
  url  = var.grafana_url
  auth = data.sops_file.grafana_secrets.data["grafana_auth"]
}
