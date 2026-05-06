resource "grafana_rule_group" "hardware_alerts" {
  name             = "Hardware & Storage Alerts"
  folder_uid       = grafana_folder.infrastructure.uid
  interval_seconds = 300

  rule {
    name           = "SMART Health Check Failed"
    condition      = "B"
    for            = "5m"
    no_data_state  = "OK" 
    exec_err_state = "Error"

    annotations = {
      summary     = "Drive {{ $labels.device }} on {{ $labels.instance }} is failing"
      description = "SMART status check failed. Drive failure may be imminent. Backup data and replace the drive."
    }

    labels = {
      severity = "critical"
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
        # 0 = Failing, 1 = Healthy. We alert if it hits 0.
        expr  = "smartctl_device_smart_status_passed == 0"
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

  rule {
    name           = "Host Temperature High (>80C)"
    condition      = "B"
    for            = "5m"
    no_data_state  = "OK"
    exec_err_state = "Error"

    annotations = {
      summary     = "Host {{ $labels.instance }} is overheating ({{ $values.B }}°C)"
      description = "A hardware sensor on the host has reported a temperature above 80°C for over 5 minutes."
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
        # We check if ANY hardware sensor goes over 80 Celsius
        expr  = "max by (instance) (node_hwmon_temp_celsius) > 80"
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

  rule {
    name           = "Low Root Disk Space (<10%)"
    condition      = "B"
    for            = "10m"
    no_data_state  = "OK"
    exec_err_state = "Error"

    annotations = {
      summary     = "Host {{ $labels.instance }} is running out of disk space"
      description = "The root filesystem (/) has less than 10% free space remaining."
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
        # Calculates available space / total space * 100. Alerts if under 10%.
        expr  = "(node_filesystem_avail_bytes{mountpoint=\"/\"} / node_filesystem_size_bytes{mountpoint=\"/\"} * 100) < 10"
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

  rule {
    name           = "ZFS Pool Degraded or Faulted"
    condition      = "B"
    for            = "5m"
    no_data_state  = "OK"
    exec_err_state = "Error"

    annotations = {
      summary     = "ZFS pool '{{ $labels.zpool }}' on {{ $labels.instance }} is {{ $labels.state }}"
      description = "The ZFS pool is not fully online. It is currently in a '{{ $labels.state }}' state. Check 'zpool status' immediately."
    }

    labels = {
      severity = "critical"
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
        expr  = "node_zfs_zpool_state{state=~\"degraded|faulted|offline|unavail\"} == 1"
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

