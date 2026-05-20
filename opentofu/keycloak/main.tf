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
  client_secret                = data.kubernetes_secret_v1.envoy_oidc.data["client-secret"]
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "https://sonarr.home.parents-basement.win/*",
    "https://radarr.home.parents-basement.win/*",
    "https://prowlarr.home.parents-basement.win/*",
    "https://qbittorrent.home.parents-basement.win/*"
  ]
  web_origins = [
    "+"
  ]
}

resource "keycloak_realm_user_profile" "homelab_profile" {
  realm_id = keycloak_realm.homelab.id

  attribute {
    name         = "username"
    display_name = "$${ro.username}"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    validator {
      name = "length"
      config = {
        min = "3"
        max = "255"
      }
    }
  }

  attribute {
    name               = "email"
    display_name       = "$${ro.email}"
    required_for_roles = ["admin", "user"]
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    validator {
      name = "email"
    }
  }

  attribute {
    name               = "firstName"
    display_name       = "$${ro.firstName}"
    required_for_roles = ["admin", "user"]
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
  }
}

resource "keycloak_user" "gorgonzola5000" {
  realm_id       = keycloak_realm.homelab.id
  username       = "gorgonzola5000"
  enabled        = true
  email          = "gorgonzola5000@michalek.sh"
  first_name     = "gorgonzola5000"
  email_verified = true

  initial_password {
    value     = data.sops_file.keycloak_secrets.data["gorgonzola5000-password"]
    temporary = false
  }
}

data "keycloak_role" "master_admin_role" {
  realm_id = "master"
  name     = "admin"
}

resource "keycloak_openid_client" "terraform_admin" {
  realm_id                 = "master"
  client_id                = "terraform-admin"
  name                     = "Permanent Terraform Admin"
  enabled                  = true
  access_type              = "CONFIDENTIAL"
  client_secret            = data.kubernetes_secret_v1.terraform_admin.data["client-secret"]
  service_accounts_enabled = true
  standard_flow_enabled    = false
}

resource "keycloak_openid_client_service_account_realm_role" "terraform_admin_roles" {
  realm_id                = "master"
  service_account_user_id = keycloak_openid_client.terraform_admin.service_account_user_id
  role                    = "admin"
}

resource "keycloak_user" "master_admin" {
  realm_id       = "master"
  username       = "keycloak" 
  enabled        = true
  email          = "keycloak-admin@michalek.sh"
  first_name     = "System"
  last_name      = "Administrator"
  email_verified = true

  initial_password {
    value     = data.sops_file.keycloak_secrets.data["keycloak-admin-password"]
    temporary = false 
  }
}

resource "keycloak_user_roles" "master_admin_binding" {
  realm_id = "master"
  user_id  = keycloak_user.master_admin.id

  role_ids = [
    data.keycloak_role.master_admin_role.id
  ]
}
