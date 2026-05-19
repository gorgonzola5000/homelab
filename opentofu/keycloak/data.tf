data "kubernetes_secret_v1" "terraform_bootstrap" {
  metadata {
    name      = "terraform-bootstrap-admin"
    namespace = "keycloak"
  }
}

data "kubernetes_secret_v1" "terraform_admin" {
  metadata {
    name      = "terraform-bootstrap-admin"
    namespace = "keycloak"
  }
}

data "kubernetes_secret_v1" "envoy_oidc" {
  metadata {
    name      = "centralized-oidc-secret"
    namespace = "envoy-gateway-system"
  }
}
