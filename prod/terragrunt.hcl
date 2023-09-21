locals {
  inventory     = jsondecode(file("inventory.json"))
  node_defaults = local.inventory.node_defaults
  nodes         = { for k, v in local.inventory.nodes : k => merge(local.inventory.node_defaults, v) }
  globals       = local.inventory.globals
}
#interfaces = ["bond0.nmn0", "bond0.hmn0", "bond0.cmn0"]
#volume_uri = "http://bootserver/nexus/repository/os-images/kubernetes-vm"

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
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in local.nodes~}
provider "libvirt" {
  alias = "${node_name}"
  uri = "${node_attrs.uri}"
}

%{endfor~}
EOF
}

generate "storage" {
  path      = "storage.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in local.nodes~}
module "${node_name}_pool" {
  source = "../modules/storage_pool"
  name = "${node_name}_images"
  providers = {
    libvirt = libvirt.${node_name}
  }
}

%{endfor~}
EOF
}

generate "locals" {
  path      = "locals.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
locals {
  inventory = jsondecode(file("inventory.json"))
  node_defaults = local.inventory.node_defaults
  nodes = { for k,v in local.inventory.nodes : k=> merge(local.inventory.node_defaults, v) }
  globals = local.inventory.globals
}

EOF
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in local.nodes~}
module "${node_name}" {
  source          = "../modules/kubernetes"
  name            = "k8s-vm-${node_attrs.role}-${node_name}"
  pool            = module.${node_name}_pool.pool
  source_image    = local.nodes.${node_name}.source_image /// "${node_attrs.source_image}"
  size = 100
  role = local.nodes.${node_name}.role
  providers = {
    libvirt = libvirt.${node_name}
  }
}

%{endfor~}
EOF
}
