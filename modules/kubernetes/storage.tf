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
resource "libvirt_pool" "base-pool-name" {
  name = var.pool
  type = "dir"
  path = "/var/lib/libvirt/${var.pool}"
}

resource "libvirt_volume" "base-volume" {
  name   = format("${var.vm_name}-base.${var.volume_format}")
  pool   = libvirt_pool.base-pool-name.name
  source = format("${var.volume_uri}-${var.volume_arch}.${var.volume_format}")
  format = var.volume_format
}

resource "libvirt_volume" "volume" {
  name           = format("${var.vm_name}.${var.volume_format}")
  pool           = libvirt_pool.base-pool-name.name
  size           = pow(1024, 3) * var.system_volume
  base_volume_id = libvirt_volume.base-volume.id
  format         = var.volume_format
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = format("${var.vm_name}_init.iso")
  pool           = libvirt_pool.base-pool-name.name
  meta_data      = data.template_file.meta_data.rendered
  network_config = data.template_file.network_config.rendered
  user_data      = data.template_file.user_data.rendered
}

data "template_file" "meta_data" {
  template = file("${path.module}/templates/meta-data.yml")
}

data "template_file" "network_config" {
  template = file("${path.module}/templates/network-config.yml")
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.yml")
}
