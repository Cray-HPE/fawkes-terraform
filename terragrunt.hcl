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
  inventory     = jsondecode(file("${get_terragrunt_dir()}/../inventory.json"))
  node_defaults = local.inventory.node_defaults
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "./terraform.tfstate"
  }
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

%{for node_name, node_attrs in local.inventory.nodes~}
%{if lookup(node_attrs, "hostname", "") != ""~}
provider "libvirt" {
  alias = "${node_name}"
  uri   = "qemu+ssh://${local.node_defaults.user.name}@${node_attrs.hostname}/system?keyfile=${local.node_defaults.user.keyfile}"
}
%{else}
provider "libvirt" {
  alias = "${node_name}"
  uri   = "qemu:///system"
}
%{endif~}

%{endfor~}
EOF
}
