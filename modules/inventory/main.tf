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
  inventory = merge([for f in fileset("${var.data_path}", "inventory/*.{yaml,json}") : yamldecode(file(format("${var.data_path}/%s", f)))]...)
  ssh_keys  = [for f in fileset("${var.data_path}", "ssh-keys/*.pub") : trimspace(file(format("${var.data_path}/%s", f)))]
  globals   = local.inventory.globals

  _hypervisor_defaults = merge(
    local.inventory.hypervisor_defaults,
    { local_networks = [for nk, nv in local.inventory.hypervisor_defaults.local_networks : merge(local.inventory.network_defaults, nv)] }
  )
  _hypervisors = { for k, v in local.inventory.hypervisors : k => merge(local._hypervisor_defaults, v) }

  hypervisors = { for k, v in local._hypervisors : k => merge(
    v,
    { "vms" = { for vmk, vmv in v.vms : vmk => merge(
      local.inventory.node_defaults,
      { "hv_name"        = k },
      { "vm_name"        = vmk },
      { "roles"          = vmv.roles },
      { "local_networks" = v.local_networks },
      { "base_volume"    = length(regexall("hypervisor(\\.local)?/system", local._hypervisors[k].uri)) > 0 ? merge(
        local.inventory.node_defaults.base_volume,
        { "uri" : replace(local.inventory.node_defaults.base_volume.uri, "bootserver", "management-vm.local") }
      ) : local.inventory.node_defaults.base_volume },
      { "volumes"        = flatten([for vk, vv in vmv.roles : local._volumes_defaults[vv]]) },
      { "ssh_keys"       = distinct(flatten([local.inventory.node_defaults.ssh_keys, local.ssh_keys])) },
      { "pci_devices"    = try(v.pci_passthrough, false) ? local._hypervisors[v.hv_name].pci_devices : [] },
      vmv
      ) }
    }
  ) }

  _volumes_defaults = { for k, v in local.inventory.volumes_defaults : k => [
    for i in v : merge(
      local.inventory.storage_pools_defaults,
      i,
      try(i.luks.key, "") != "" ? { "luks" = merge(i.luks, local.luks_keys[i.luks.key]) } : {}
    )]
  }

  luks_keys = { for k, v in local.inventory.luks_keys : k => merge(
    v,
    { "content" = random_password.luks_key[k].result }
  ) }
}

resource "random_password" "luks_key" {
  for_each = local.inventory.luks_keys
  length   = try(each.value.length, 128)
  special  = true
}
