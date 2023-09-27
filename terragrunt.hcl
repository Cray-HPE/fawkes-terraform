locals {
  inventory     = jsondecode(file("${get_terragrunt_dir()}/inventory.json"))
  node_defaults = local.inventory.node_defaults
  nodes         = { for k, v in local.inventory.nodes : k => merge(local.inventory.node_defaults, v) }
  globals       = local.inventory.globals
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

EOF
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in local.nodes~}
provider "libvirt" {
  alias = "${node_name}"
  uri   = "${node_attrs.uri}"
}

%{endfor~}
EOF
}

generate "locals" {
  path      = "locals.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
locals {
  inventory     = jsondecode(file("inventory.json"))
  node_defaults = local.inventory.node_defaults
  nodes         = { for k,v in local.inventory.nodes : k=> merge(local.inventory.node_defaults, v) }
  globals       = local.inventory.globals
}

EOF
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in local.nodes~}
module "${node_name}-kubernetes-${node_attrs.sub_role}" {
  source        = "./kubernetes"
  name          = "kubernetes-${node_attrs.sub_role}-${node_name}"
  interfaces    = ${jsonencode("${node_attrs}".interfaces)}
  pool          = module.${node_name}-storage-pool.pool
  sub_role      = local.nodes.${node_name}.sub_role
  volume_size   = local.nodes.${node_name}.volume_size
  volume_name   = local.nodes.${node_name}.volume_name
  volume_format = local.nodes.${node_name}.volume_format
  volume_arch   = local.nodes.${node_name}.volume_arch
%{if strcontains(node_attrs.uri, "hypervisor.local/system") || strcontains(node_attrs.uri, "hypervisor/system") ~}
  volume_uri    = "${ replace(node_attrs.volume_uri, "bootserver", "management-vm.local") }"
%{else~}
  volume_uri    = local.nodes.${node_name}.volume_uri
%{endif~}
  providers     = {
    libvirt = libvirt.${node_name}
  }
}

module "${node_name}-storage-pool" {
  source    = "./storage_pool"
  name      = "${node_name}-storage-pool"
  providers = {
    libvirt = libvirt.${node_name}
  }
}

%{endfor~}
EOF
}
