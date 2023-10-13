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

include {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/noop"
}

generate "network" {
  path      = "network.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{for hv_name, hv_attrs in include.locals.local_networks~}
module "${hv_name}-isolated-network" {
  source    = "${get_parent_terragrunt_dir()}/modules/network"
  name      = local.local_networks.${hv_name}.local_network.name
  addresses = local.local_networks.${hv_name}.local_network.addresses
  mtu       = local.local_networks.${hv_name}.local_network.mtu
  mode      = local.local_networks.${hv_name}.local_network.mode
  dhcp4     = local.local_networks.${hv_name}.local_network.dhcp4
  dhcp6     = local.local_networks.${hv_name}.local_network.dhcp6
  providers = {
    libvirt = libvirt.${hv_name}
  }
}
%{endfor~}
EOF
}
