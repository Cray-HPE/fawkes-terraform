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
  volumes = { for k, v in var.volumes : "${k}-${v.name}" => v }
  pools   = { for v in var.volumes : (v.pool.name) => v.pool.prefix... }
  # This results in :
  #  {
  #    "default" = [
  #      "/var/lib/libvirt",
  #      "/var/lib/libvirt",
  #      "/var/lib/libvirt",
  #      "/var/lib/libvirt",
  #    ]
  #    "etcd" = [
  #      "/var/lib/etcd",
  #    ]
  #  }
  # which is not super elegant, but it works with each.value[0].
  # I don't have a solution to compact the value.
  _network_interfaces = flatten([
    [
      for k, v in local.local_networks :
      {
        dhcp4     = v.dhcp4,
        dhcp6     = v.dhcp6,
        mtu       = v.mtu,
        addresses = v.addresses
      }
    ],
    [
      for k, v in var.network_interfaces :
      {
        dhcp4 = v.dhcp4,
        dhcp6 = v.dhcp6,
        mtu   = v.mtu,
      }
    ]
  ])
  network_interfaces = { for k, v in local._network_interfaces : "eth${k}" => v }
  # add a generated addresses attribute, based on the index of the current domain
  local_networks = { for k, v in var.local_networks : k => merge(v, { addresses = [cidrhost(v.addresses, split("-", v.dhcp4_range)[0] + var.index)] }) }

  prefix   = var.prefix != "" ? "${var.prefix}-" : ""
  hostname = "${local.prefix}${var.hypervisor_name}-${var.name}-${var.roles[0]}"
  # the yamldecode calls will fail if the templates do not generate valid YAML
  validate_cloudinit_meta_data      = yamldecode(libvirt_cloudinit_disk.init.meta_data)
  validate_cloudinit_network_config = yamldecode(libvirt_cloudinit_disk.init.network_config)
  validate_cloudinit_user_data      = yamldecode(libvirt_cloudinit_disk.init.user_data)
}

resource "libvirt_pool" "pool" {
  for_each = local.pools
  name     = "${local.hostname}-storage-pool-${each.key}"
  type     = "dir"
  path     = "${each.value[0]}/${local.hostname}-storage-pool-${each.key}"
}

# Base OS image
resource "libvirt_volume" "base" {
  name   = "${local.hostname}-base.${var.volume_format}"
  source = "${var.base_volume.uri}/${var.base_volume.name}-${var.base_volume.arch}.${var.base_volume.format}"
  pool   = libvirt_pool.pool["default"].name
  format = var.volume_format
}

resource "libvirt_volume" "vol" {
  for_each       = local.volumes
  name           = "${local.hostname}-${each.key}.${var.volume_format}"
  base_volume_id = try(each.value.use_base_volume, false) ? libvirt_volume.base.id : null
  pool           = libvirt_pool.pool[each.value.pool.name].name
  format         = try(each.value.format, var.volume_format)
  size           = try(each.value.size, var.default_volume_size) * pow(1024, 3)
}

resource "libvirt_cloudinit_disk" "init" {
  name = "${local.hostname}-init.iso"
  pool = libvirt_pool.pool["default"].name
  meta_data = templatefile("${path.module}/templates/meta-data.yml",
    {
      hostname = local.hostname
  })
  network_config = templatefile("${path.module}/templates/network-config.yml",
    {
      interfaces = local.network_interfaces
  })
  user_data = templatefile("${path.module}/templates/user-data.yml",
    {
      hostname = local.hostname
      volumes  = local.volumes
      ssh_keys = var.ssh_keys
  })
}

resource "libvirt_domain" "vm" {
  name       = local.hostname
  memory     = var.memory
  vcpu       = var.vcpu
  autostart  = true
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.init.id

  dynamic "network_interface" {
    for_each = local.local_networks
    content {
      addresses      = network_interface.value.static ? network_interface.value.addresses : null
      network_id     = network_interface.value.create ? network_interface.value.id : null
      network_name   = network_interface.value.create ? null : network_interface.value.name
      hostname       = local.hostname
      wait_for_lease = true
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      mac         = try(network_interface.value.mac, null)
      addresses   = try(network_interface.value.addresses, null)
      bridge      = network_interface.value.mode == "bridge" ? network_interface.value.target : null
      vepa        = network_interface.value.mode == "vepa" ? network_interface.value.target : null
      macvtap     = network_interface.value.mode == "macvtap" ? network_interface.value.target : null
      passthrough = network_interface.value.mode == "passthrough" ? network_interface.value.target : null
    }
  }

  dynamic "disk" {
    for_each = local.volumes
    content {
      volume_id = libvirt_volume.vol[disk.key].id
      scsi      = true
      wwn       = disk.value.wwn
    }
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  xml {
    xslt = templatefile("${path.module}/templates/domain-xslt.xml.tpl", {
      pci_data      = distinct(flatten([for k,v in var.hardware: v.iommu_group_addresses]))
      disable_spice = var.disable_spice
    })
  }
}

output "hardware" {
  value = var.hardware
}