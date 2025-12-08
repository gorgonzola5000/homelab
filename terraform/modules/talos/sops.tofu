data "sops_file" "secret_zero" {
  source_file = var.encrypted_age_key_path
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }

  depends_on = [
    helm_release.cilium
  ]
}

resource "kubernetes_secret" "sops_age" {
  metadata {
    name      = "sops-age"
    namespace = kubernetes_namespace.flux_system.metadata[0].name
  }

  data = {
    "age.agekey" = data.sops_file.secret_zero.data[var.age_key_yaml_key]
  }

  type = "Opaque"
}
