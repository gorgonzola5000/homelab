variable "enable_health_check" {
  description = "Enable cluster health check (set to false when destroying)"
  type        = bool
  default     = true
}

variable "interface" {
  description = "Network interface name for static IP during bootstrap"
  type        = string
  default     = "eth0"
}

variable "cluster_name" {
  description = "Name of the cluster to use"
  type        = string
}

variable "kubernetes_endpoint" {
  description = "Kubernetes endpoint - public IP address for AWS or private IP address for local"
  type        = string
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

variable "mac_address" {
  description = "Mac address of the network interface of the Kubernetes node"
  type        = string
}

variable "ip" {
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

variable "install_disk" {
  type = object({
    machine = object({
      install = object({
        disk = optional(string)
        diskSelector = optional(object({
          uuid    = optional(string)
          wwid    = optional(string)
          busPath = optional(string)
        }))
      })
    })
  })
  default = null
  validation {
    condition     = var.is_bare_metal ? (var.install_disk != null) : true
    error_message = "The 'install_disk' variable must be set when 'is_bare_metal' is true."
  }
}

variable "talos_installer_url" {
  description = "The URL for the Talos installer"
  type        = string
}

variable "is_bare_metal" {
  description = "Set to true if deploying to bare metal."
  type        = bool
  default     = false
}
