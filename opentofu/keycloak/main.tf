resource "keycloak_realm" "homelab" {
  realm        = "homelab"
  enabled      = true
  display_name = "Meddle Single Sign-On"
}

resource "keycloak_openid_client" "envoy_gateway" {
  realm_id                     = keycloak_realm.homelab.id
  client_id                    = "envoy-gateway"
  name                         = "Envoy SSO Gateway"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  
  client_secret                = data.kubernetes_secret.envoy_oidc.data["client-secret"]
  
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  
  valid_redirect_uris = [
    "https://sonarr.home.parents-basement.win/*",
    "https://radarr.home.parents-basement.win/*",
    "https://prowlarr.home.parents-basement.win/*"
  ]
  
  web_origins = [
    "+"
  ]
}

resource "keycloak_user" "gorgonzola5000" {
  realm_id       = keycloak_realm.homelab.id
  username       = "gorgonzola5000"
  enabled        = true
  email          = "gorgonzola5000@michalek.sh"
  first_name     = "gorgonzola5000"
  email_verified = true

  initial_password {
    value     = data.sops_file.opentofu_secrets.data["gorgonzola5000-password"]
    temporary = false
  }
}
