resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version_contract
}

data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

# compute the latest version dynamically
locals {
  latest_talos_version = element(
    data.talos_image_factory_versions.this.talos_versions,
    length(data.talos_image_factory_versions.this.talos_versions) - 1
  )
}

output "latest" {
  value = local.latest_talos_version
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = local.latest_talos_version
  filters = {
    names = [
      "zfs",
      "intel-ucode",
      "i915",
      "qemu-guest-agent",
      "util-linux-tools",
    ]
  }
}

output "image_schematic_url" {
  value = data.talos_image_factory_urls.this.urls.disk_image
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
        extraKernelArgs = [
          format(
            "ip=%s::%s:%s:%s:%s:off",
            var.ip,
            var.gateway,
            cidrnetmask("0.0.0.0${var.subnet_mask}"),
            var.hostname,
            var.interface
          )
        ]
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  talos_version = local.latest_talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
  architecture  = "amd64"
}

output "installer_image" {
  value = data.talos_image_factory_urls.this.urls.installer
}

locals {
  base_config_patches = [
    templatefile("${path.module}/machine-config.yaml.tftpl", {
      hostname            = var.hostname
      mac_address         = var.mac_address
      ip                  = var.ip
      subnet_mask         = var.subnet_mask
      gateway             = var.gateway
      talos_image         = data.talos_image_factory_urls.this.urls.installer
      kubernetes_endpoint = var.kubernetes_endpoint
    })
  ]

  bare_metal_patches = var.is_bare_metal ? [yamlencode(var.install_disk)] : []
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.kubernetes_endpoint}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version_contract
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false
  config_patches     = concat(local.base_config_patches, local.bare_metal_patches)
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.ip
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.ip
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [var.ip]
  endpoints            = [var.kubernetes_endpoint]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.ip
}

data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_cluster_kubeconfig.this,
    helm_release.cilium
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.kubernetes_endpoint]
  control_plane_nodes  = [var.ip]
}

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = pathexpand("~/.kube/config_${var.cluster_name}")
  file_permission = "0600"
}

resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = pathexpand("~/.talos/config_${var.cluster_name}")
  file_permission = "0600"

  provisioner "local-exec" {
    command    = "talosctl config merge ~/.talos/config_${var.cluster_name}"
    on_failure = continue
  }
}
