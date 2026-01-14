resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version_contract
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version_contract
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
  talos_version = var.talos_version_contract
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
  architecture  = "amd64"
}

output "installer_image" {
  value = data.talos_image_factory_urls.this.urls.installer
}

locals {
  base_config_patches = [
    templatefile("${path.module}/talos-configs/MachineConfig.yaml.tftpl", {
      mac_address         = var.mac_address
      talos_image         = data.talos_image_factory_urls.this.urls.installer
      kubernetes_endpoint = var.kubernetes_endpoint
    }),
    templatefile("${path.module}/talos-configs/HostnameConfig.yaml.tftpl", {
      hostname = var.hostname
    })
    #    templatefile("${path.module}/talos-configs/LinkAliasConfig.yaml.tftpl", {
    #      mac_address = var.mac_address
    #    }),
    #    templatefile("${path.module}/talos-configs/LinkConfig.yaml.tftpl", {
    #      ip          = var.ip
    #      subnet_mask = var.subnet_mask
    #      gateway     = var.gateway
    #    })
  ]
  bare_metal_patches     = var.is_bare_metal ? [yamlencode(var.install_disk)] : []
  install_config_patches = concat(local.base_config_patches, local.bare_metal_patches)

  zfs_disk_patches = [
    for i, wwid in var.disk_wwids : templatefile("${path.module}/talos-configs/RawVolumeConfig.yaml.tftpl", {
      index      = tostring(i)
      wwid       = wwid
      passphrase = var.zfs_pool_passphrase
    })
  ]

  cilium_patch = [yamlencode({
    cluster = {
      inlineManifests = [
        {
          name     = "cilium"
          contents = data.helm_template.cilium.manifest
        }
      ]
    }
  })]

  flux_sops_secret_manifest = [yamlencode({
    cluster = {
      inlineManifests = [
        {
          name     = "flux-sops"
          contents = data.sops_file.flux_secret.raw
        }
      ]
    }
  })]

  flux_ns_manifest = [yamlencode({
    cluster = {
      inlineManifests = [
        {
          name = "flux-system-namespace"
          contents = yamlencode({
            apiVersion = "v1"
            kind       = "Namespace"
            metadata = {
              name = "flux-system"
            }
            }
          )
        }
      ]
    }
  })]

  flux_instance = [yamlencode({
    cluster = {
      inlineManifests = [
        {
          name = "flux-instance"
          contents = templatefile("${path.module}/kubernetes-manifests/flux-instance.yaml.tftpl", {
            cluster_name = var.cluster_name
            }
          )
      }]
    }
  })]
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
  config_patches = flatten([
    local.install_config_patches,
    local.zfs_disk_patches,
    local.cilium_patch,
    local.flux_ns_manifest,
    local.flux_sops_secret_manifest,
    local.flux_instance,
  ])
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
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.kubernetes_endpoint]
  control_plane_nodes  = [var.ip]
}

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = "${path.root}/../../sops/${var.cluster_name}/kube_config_${var.cluster_name}.enc"
  file_permission = "0600"
}

resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = "${path.root}/../../sops/${var.cluster_name}/talos_config_${var.cluster_name}.enc"
  file_permission = "0600"

  provisioner "local-exec" {
    command    = "talosctl config merge ~/.talos/config_${var.cluster_name}"
    on_failure = continue
  }
}
