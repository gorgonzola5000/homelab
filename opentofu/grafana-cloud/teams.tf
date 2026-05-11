resource "grafana_team" "sysadmin" {
  name  = "sysadmin"
  email = data.sops_file.grafana_secrets.data["alert_email_address"]
  members = [
    data.sops_file.grafana_secrets.data["alert_email_address"]
  ]
}
