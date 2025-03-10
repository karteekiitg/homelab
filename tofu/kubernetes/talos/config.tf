resource "talos_machine_secrets" "this" {
  talos_version = var.image.update_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in var.nodes : v.ip]
  endpoints            = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
}

data "talos_machine_configuration" "this" {
  for_each         = var.nodes
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = each.value.update == true ? var.image.update_version : var.image.version
  machine_type     = each.value.machine_type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.cluster.kubernetes_version
  config_patches   = each.value.machine_type == "controlplane" ? [
    templatefile("${path.module}/machine-config/control-plane.yaml.tftpl", {
      cilium_values  = var.cilium.values
      cilium_install = var.cilium.install
      base_domain    = var.cluster.base_domain
    })
    , templatefile("${path.module}/machine-config/common.yaml.tftpl", {
      node_name      = each.value.host_node
      cluster_name   = var.cluster.proxmox_cluster
    })
    , var.cluster.vip != null ? templatefile("${path.module}/machine-config/control-plane-vip.yaml.tftpl", {
      hostname       = each.key
      ip             = each.value.ip
      mac_address    = lower(each.value.mac_address)
      gateway        = var.cluster.gateway
      subnet_mask    = var.cluster.subnet_mask
      vip            = var.cluster.vip
    }) : ""] : [
    templatefile("${path.module}/machine-config/worker.yaml.tftpl", {
      hostname       = each.key
      ip             = each.value.ip
      mac_address    = lower(each.value.mac_address)
      gateway        = var.cluster.gateway
      subnet_mask    = var.cluster.subnet_mask
    })
    , templatefile("${path.module}/machine-config/common.yaml.tftpl", {
      node_name      = each.value.host_node
      cluster_name   = var.cluster.proxmox_cluster
    })
  ]
}

resource "talos_machine_configuration_apply" "this" {
  depends_on = [proxmox_virtual_environment_vm.this]
  for_each                    = var.nodes
  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  lifecycle {
    # re-run config apply if vm changes
    replace_triggered_by = [proxmox_virtual_environment_vm.this[each.key]]
  }
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.this]
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]
  skip_kubernetes_checks = false
  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes  = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
  worker_nodes         = [for k, v in var.nodes : v.ip if v.machine_type == "worker"]
  endpoints            = data.talos_client_configuration.this.endpoints
  timeouts = {
    read = "10m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
    data.talos_cluster_health.this
  ]
  node                 = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read = "1m"
  }
}
