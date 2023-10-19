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

module "domain" {
  for_each = var.domains
  source = "./kubernetes"

  environment         = var.environment
  vcpu                = each.value.vcpu
  memory              = each.value.memory
  name                = each.key
  network_interfaces  = each.value.network_interfaces
  base_volume         = each.value.base_volume
  # this grabs the network_id for the ones we created
  local_networks      = [ for k,v in each.value.local_networks : merge(
    v,
    (v.create ? { "id" = module.network.id[v.name]} : {})
  )]
  roles               = each.value.roles
  volumes             = each.value.volumes
  ssh_keys            = each.value.ssh_keys
}

# change to for_each and use network
module "network" {
  source = "./networks"
  networks = var.local_networks
}
