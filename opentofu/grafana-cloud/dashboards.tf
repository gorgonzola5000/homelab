resource "grafana_dashboard" "debian_overview" {
  folder      = grafana_folder.infrastructure.id
  config_json = file("${path.module}/dashboards/debian_overview.json")
  overwrite   = true
}
