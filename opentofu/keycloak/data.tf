data "kubernetes_secret" "terraform_bootstrap" {
  metadata {
    name      = "terraform-bootstrap-admin"
    namespace = "keycloak"
  }
}

data "kubernetes_secret" "terraform_admin" {
  metadata {
    name      = "terraform-bootstrap-admin"
    namespace = "keycloak"
  }
}

data "kubernetes_secret" "envoy_oidc" {
  metadata {
    name      = "centralized-oidc-secret"
    namespace = "envoy-gateway-system"
  }
}
