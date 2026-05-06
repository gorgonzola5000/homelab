resource "grafana_rule_group" "debian_os_alerts" {
  name             = "Debian OS Alerts"
  folder_uid       = grafana_folder.infrastructure.uid
  interval_seconds = 300

  rule {
    name           = "Debian Reboot Required"
    condition      = "B"
    for            = "10m"
    no_data_state  = "OK"
    exec_err_state = "Error"

    annotations = {
      summary     = "Debian Host {{ $labels.instance }} requires a reboot"
      description = "A kernel update or system library has been installed. A reboot is pending."
    }

    labels = {
      severity = "warning"
      team     = "sysadmin"
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      relative_time_range {
        from = 600
        to   = 0
      }
      model = jsonencode({
        expr  = "node_reboot_required == 1"
        refId = "A"
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        type       = "reduce"
        expression = "A"
        reducer    = "last"
        refId      = "B"
      })
    }
  }
}
