variable "interface" {
  description = "Network interface name for static IP during bootstrap"
  type        = string
  default     = "eth0"
}

variable "talos_version_contract" {
  description = "Talos API version to use for the cluster, if not set the the version shipped with the talos sdk version will be used"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster, if not set the k8s version shipped with the talos sdk version will be used"
  type        = string
  default     = null
}

variable "hostname" {
  description = "Hostname of the Kubernetes node"
  type        = string
}

variable "static_ip" {
  description = "IP address of the node"
  type        = string
}

variable "subnet_mask" {
  description = "Subnet mask e.g. '/24'"
  type        = string
}

variable "gateway" {
  description = "Gateway's IP address"
  type        = string
}
