output "image_schematic_url" {
  value = data.talos_image_factory_urls.this.urls.disk_image
}

output "latest" {
  value = local.latest_talos_version
}

output "installer_image_url" {
  value = data.talos_image_factory_urls.this.urls.installer
}

output "raw_image_url" {
  value = data.talos_image_factory_urls.this.urls.disk_image
}
