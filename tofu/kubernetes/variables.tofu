variable "proxmox" {
  description = "Proxmox provider configuration"
  type = object({
    name         = string
    cluster_name = string
    endpoint     = string
    insecure     = bool
    username     = string
  })
}

variable "proxmox_api_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
  default     = null
}

variable "tofu_encryption_passphrase" {
  description = "State encryption passphrase"
  type        = string
  sensitive   = true
  default     = null
}

variable "talos_image" {
  description = "Talos image configuration"
  type = object({
    factory_url           = optional(string, "https://factory.talos.dev")
    version               = string
    schematic_path        = string
    update_version        = optional(string)
    update_schematic_path = optional(string)
    arch                  = optional(string, "amd64")
    platform              = optional(string, "nocloud")
    proxmox_datastore     = optional(string, "local")
  })
}

variable "talos_cluster_config" {
  description = "Talos cluster configuration"
  type = object({
    name                         = string
    vip                          = optional(string)
    gateway                      = string
    subnet_mask                  = optional(string, "24")
    talos_machine_config_version = optional(string)
    proxmox_cluster              = string
    kubernetes_version           = string
    gateway_api_version          = string
    extra_manifests              = optional(list(string), [])
    kubelet                      = optional(string)
    api_server                   = optional(string)
    cilium = object({
      bootstrap_manifest_path = string
      values_file_path        = string
    })
  })
}

variable "talos_nodes" {
  type = map(
    object({
      host_node     = string
      machine_type  = string
      ip            = string
      dns           = optional(list(string))
      mac_address   = string
      vm_id         = number
      cpu           = number
      ram_dedicated = number
      update        = optional(bool, false)
      igpu          = optional(bool, false)
    })
  )
  validation {
    // @formatter:off
    condition     = length([for n in var.talos_nodes : n if contains(["controlplane", "worker"], n.machine_type)]) == length(var.talos_nodes)
    error_message = "Node machine_type must be either 'controlplane' or 'worker'."
    // @formatter:on
  }
}

variable "sealed_secrets_config" {
  description = "Sealed-secrets configuration"
  type = object({
    certificate_path     = string
    certificate_key_path = string
  })
}

variable "kubernetes_volumes" {
  type = map(
    object({
      node    = string
      size    = string
      storage = optional(string, "local-zfs")
      vmid    = optional(number, 9999)
      format  = optional(string, "raw")
    })
  )
}

# Define a variable for the bucket name.
# Set this in .env file in root, which should automatically set it in devcontainer env.
variable "bucket_name" {
  description = "The globally unique name for the bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, alphanumeric, and hyphens only."
  }

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters."
  }
}

# Define a variable for part of bucket prefix.
# This should be set automatically based on branch logic in devcontainer.
variable "branch_env" {
  description = "Part of bucket prefix."
  type        = string
}
