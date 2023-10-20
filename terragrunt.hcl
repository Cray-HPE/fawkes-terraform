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

# The nodes and hypervisors here are minimal just for code generation
# The real locals are in the generate block further down
locals {
  inventory = merge([for f in fileset("${get_terragrunt_dir()}", "inventory/*.{yaml,json}") : yamldecode(file(format("${get_terragrunt_dir()}/%s", f)))]...)
  globals   = local.inventory.globals
  # this is all terragrunt needs: list of hypervisors merged with defaults (for uri)
  hypervisors = { for k, v in local.inventory.hypervisors : k => merge(local.inventory.hypervisor_defaults, v) }
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

generate "inventory" {
  path = "inventory.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
module "inventory" {
  source    = "${get_parent_terragrunt_dir()}/modules/inventory"
  data_path = "${get_terragrunt_dir()}"
}
EOF
}

generate "hypervisors" {
  path      = "hypervisors.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for hv_name, hv_attrs in local.hypervisors~}
module "${hv_name}-hypervisor" {
  source              = "${get_parent_terragrunt_dir()}/modules/hypervisor"

  environment         = module.inventory.globals.env_name
  prefix              = module.inventory.globals.prefix
  hypervisor_name     = "${hv_name}"
  local_networks      = module.inventory.hypervisors.${hv_name}.local_networks
  domains             = module.inventory.hypervisors.${hv_name}.vms

  providers           = {
    libvirt = libvirt.${hv_name}
  }
}
%{endfor~}
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
