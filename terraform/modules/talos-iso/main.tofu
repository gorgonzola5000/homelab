data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

locals {
  latest_talos_version = element(
    data.talos_image_factory_versions.this.talos_versions,
    length(data.talos_image_factory_versions.this.talos_versions) - 1
  )
}

data "talos_image_factory_extensions_versions" "this" {
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

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
        extraKernelArgs = [
          format(
            "ip=%s::%s:%s:%s:%s::::",
            var.static_ip,
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
