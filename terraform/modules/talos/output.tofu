output "kubeconfig" {
  description = "The kubeconfig for the Talos cluster (raw string)"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "The Talos client configuration (raw string)"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubernetes_cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate (PEM)"
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
}

output "kubernetes_client_certificate" {
  description = "Kubernetes client certificate (PEM)"
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  sensitive   = true
}

output "kubernetes_client_key" {
  description = "Kubernetes client key (PEM)"
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  sensitive   = true
}
