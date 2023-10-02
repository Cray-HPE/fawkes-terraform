#
# MIT License
#
# (C) Copyright 2023 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
locals {
  inventory     = jsondecode(file("${get_terragrunt_dir()}/inventory.json"))
  node_defaults = local.inventory.node_defaults
  nodes         = { for k, v in local.inventory.nodes : k => merge(local.inventory.node_defaults, v) }
  globals       = local.inventory.globals
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
EOF
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
  source        = "${get_parent_terragrunt_dir()}/modules/kubernetes"
  cpus          = local.nodes.${node_name}.vcpu
  memory        = local.nodes.${node_name}.memory
  name          = "kubernetes-${node_attrs.sub_role}-${node_name}"
  interfaces    = ${jsonencode("${node_attrs}".interfaces)}
  pool          = module.${node_name}-storage-pool.pool
  volume_arch   = local.nodes.${node_name}.volume_arch
  sub_role      = local.nodes.${node_name}.sub_role
  volume_format = local.nodes.${node_name}.volume_format
  volume_name   = local.nodes.${node_name}.volume_name
  volume_size   = local.nodes.${node_name}.volume_size
%{if strcontains(node_attrs.uri, "hypervisor.local/system") || strcontains(node_attrs.uri, "hypervisor/system")~}
  volume_uri    = "${replace(node_attrs.volume_uri, "bootserver", "management-vm.local")}"
%{else~}
  volume_uri    = local.nodes.${node_name}.volume_uri
%{endif~}
  providers     = {
    libvirt = libvirt.${node_name}
  }
}

module "${node_name}-storage-pool" {
  source    = "${get_parent_terragrunt_dir()}/modules/storage_pool"
  name      = "${node_name}-storage-pool"
  providers = {
    libvirt = libvirt.${node_name}
  }
}

%{endfor~}
EOF
}
