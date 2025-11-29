resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "gitlab_project" "this" {
  path_with_namespace = "starfruit6000/homelab"
}

resource "gitlab_deploy_key" "this" {
  project  = data.gitlab_project.this.path_with_namespace
  title    = "Flux"
  key      = tls_private_key.flux.public_key_openssh
  can_push = true
}

resource "flux_bootstrap_git" "this" {
  depends_on = [gitlab_deploy_key.this, module.talos]

  embedded_manifests = true
  path               = "./kubernetes/clusters/${local.talos_cluster_name}"
}
