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
include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../_env/kubernetes.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_url}"
}

dependency "storage_pool" {
  config_path = "../storage_pool"
  mock_outputs = {
    pool = "kubernetes_pool"
  }
}

inputs = {
  pool = dependency.storage_pool.outputs.pool
}

generate "modules" {
  path      = "modules.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for node_name, node_attrs in include.env.locals.env_vars.locals.inventory.nodes~}
%{if node_attrs.role == "worker"~}
module "kubernetes-worker-${node_name}" {
  name          = "kubernetes-worker-${node_name}"
  source        = "${include.env.locals.source_url}"
  pool          = "kubernetes-worker-${node_name}"
  interfaces    = ${jsonencode(include.env.locals.env_vars.locals.interfaces)}
  volume_arch   = "${include.env.locals.env_vars.locals.volume_arch}"
  volume_uri    = "${include.env.locals.env_vars.locals.volume_uri}"
  volume_size   = ${include.env.locals.env_vars.locals.volume_size}
  providers = {
    libvirt = libvirt.${node_name}
  }
}
%{endif~}
%{endfor~}
EOF
}
