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
}

resource "libvirt_pool" "pool" {
  name = "${var.name}-storage-pool"
  type = "dir"
  path = "${var.storage_pool_prefix}/${var.name}-storage-pool"
}

# Base OS image
resource "libvirt_volume" "base" {
  name   = "${var.name}-base.${var.volume_format}"
  source = "${var.base_volume.uri}/${var.base_volume.name}-${var.base_volume.arch}.${var.base_volume.format}"
  pool   = libvirt_pool.pool.name
  format = var.volume_format
}

resource "libvirt_volume" "vol" {
  for_each       = local.volumes
  name           = "${var.name}-${each.key}.${var.volume_format}"
  base_volume_id = try(each.value.use_base_volume, false) ? libvirt_volume.base.id : null
  pool           = libvirt_pool.pool.name
  format         = try(each.value.format, var.volume_format)
  size           = try(each.value.size, var.default_volume_size) * pow(1024, 3)
}

resource "libvirt_cloudinit_disk" "init" {
  name = "${var.name}-init.iso"
  pool = libvirt_pool.pool.name
  meta_data = templatefile("${path.module}/templates/meta-data.yml",
    {
      hostname = var.name
  })
  network_config = templatefile("${path.module}/templates/network-config.yml",
    {

  })
  user_data = templatefile("${path.module}/templates/user-data.yml",
    {
      hostname = var.name
      volumes  = local.volumes
      ssh_keys = var.ssh_keys
  })
}

resource "libvirt_domain" "vm" {
  name       = var.name
  memory     = var.memory
  vcpu       = var.vcpu
  autostart  = true
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.init.id

  dynamic "network_interface" {
    for_each = var.local_networks
    content {
      network_id     = network_interface.value
      hostname       = var.name
      wait_for_lease = true
    }
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      macvtap = network_interface.value
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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}
