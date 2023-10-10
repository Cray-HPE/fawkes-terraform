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
terraform_version_constraint  = "<0.14"
terragrunt_version_constraint = "<0.52"

locals {
  inventory      = yamldecode(file("${get_terragrunt_dir()}/inventory.yaml"))
  local_networks = { for k, v in local.hypervisors : k => v if try(v.local_network.name, "") != "" }
  _nodes = flatten(
    [
      for k, v in local.hypervisors :
      [
        for vm, vmv in v.vms : merge(
          { hv_name : k },
          { vm_name : vm },
          { role : try(vmv.roles[0], "undef") },
          { local_networks : try([v.local_network.name], []) },
          vmv
        )
      ] if try(v.vms, {}) != {}
    ]
  )
  _volumes_defaults = { for k, v in local.inventory.volumes_defaults : k => [for i in v : merge(local.inventory.storage_pools_defaults, i)] }
  hypervisors       = { for k, v in local.inventory.hypervisors : k => merge(local.inventory.hypervisor_defaults, v) }
  nodes = { for k, v in local._nodes : (format("%s-%s", v.hv_name, v.vm_name)) => merge(
    local.inventory.node_defaults,
    v,
    { "base_volume" = length(regexall("hypervisor(\\.local)?/system", local.hypervisors[v.hv_name].uri)) > 0 ? merge(
      local.inventory.node_defaults.base_volume,
      {
        "uri" : replace(local.inventory.node_defaults.base_volume.uri, "bootserver", "management-vm.local")
      }
    ) : local.inventory.node_defaults.base_volume },
    { "volumes" = flatten([for k, v in v.roles : local._volumes_defaults[v]]) }
  ) }
  globals = local.inventory.globals
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
%{for hv_name, hv_attrs in local.hypervisors~}
provider "libvirt" {
  alias = "${hv_name}"
  uri   = "${hv_attrs.uri}"
}
%{endfor~}
EOF
}

generate "locals" {
  path      = "locals.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
locals {
  inventory      = yamldecode(file("${get_terragrunt_dir()}/inventory.yaml"))
  local_networks = { for k, v in local.hypervisors : k => v if try(v.local_network.name, "") != "" }
  _nodes = flatten(
    [
      for k,v in local.hypervisors :
        [
          for vm, vmv in v.vms : merge(
              { hv_name : k },
              { vm_name : vm },
              { role : try(vmv.roles[0], "undef") },
              { local_networks : try([v.local_network.name], []) },
              vmv
            )
          ] if try(v.vms, {}) != {}
    ]
  )
  _volumes_defaults = { for k, v in local.inventory.volumes_defaults : k => [for i in v : merge(local.inventory.storage_pools_defaults, i)] }
  hypervisors       = { for k, v in local.inventory.hypervisors : k=> merge(local.inventory.hypervisor_defaults, v) }
  nodes = { for k, v in local._nodes : (format("%s-%s", v.hv_name, v.vm_name)) => merge(
    local.inventory.node_defaults,
    v,
    { "base_volume" = length(regexall("hypervisor(\\.local)?/system", local.hypervisors[v.hv_name].uri)) > 0 ? merge(
      local.inventory.node_defaults.base_volume,
      {
        "uri" : replace(local.inventory.node_defaults.base_volume.uri, "bootserver", "management-vm.local")
      }
    ) : local.inventory.node_defaults.base_volume },
    { "volumes" = flatten([for k, v in v.roles : local._volumes_defaults[v]]) }
  ) }
  globals     = local.inventory.globals
}
EOF
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in local.nodes~}
module "${node_name}-kubernetes-${node_attrs.role}" {
  vcpu                = local.nodes.${node_name}.vcpu
  memory              = local.nodes.${node_name}.memory
  environment         = local.globals.env_name
  source              = "${get_parent_terragrunt_dir()}/modules/kubernetes"
  name                = "kubernetes-${node_attrs.role}-${node_name}"
  interfaces          = local.nodes.${node_name}.interfaces
  base_volume         = local.nodes.${node_name}.base_volume
%{if try(local.hypervisors[node_attrs.hv_name].local_network, {}) != {} ~}
  local_networks      = [module.${node_attrs.hv_name}-isolated-network.id]
%{endif}
  roles               = local.nodes.${node_name}.roles
  volumes             = local.nodes.${node_name}.volumes
  ssh_keys            = local.nodes.${node_name}.ssh_keys
  providers           = {
    libvirt = libvirt.${node_attrs.hv_name}
  }
}
%{endfor~}
EOF
}
