data "sops_file" "flux_secret" {
  source_file = var.encrypted_age_key_path
}
