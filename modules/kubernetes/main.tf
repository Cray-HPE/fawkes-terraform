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
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

# Base OS image
resource "libvirt_volume" "base-volume" {
  name   = "${var.name}-base.${var.volume_format}"
  source = "${var.volume_uri}/${var.volume_name}-${var.volume_arch}.${var.volume_format}"
  pool   = var.pool
  format = var.volume_format
}

# Create a virtual disk per host based on the Base OS Image
resource "libvirt_volume" "volume" {
  name           = "${var.name}.${var.volume_format}"
  base_volume_id = libvirt_volume.base-volume.id
  pool           = var.pool
  format         = var.volume_format
  size           = pow(1024, 3) * var.volume_size
}

resource "libvirt_volume" "etcd" {
  count  = var.sub_role == "master" ? 1 : 0
  name   = "${var.name}_etcd.${var.volume_format}"
  pool   = var.pool /// Put this in different pool
  format = var.volume_format
  size   = pow(1024, 3) * 32
}

resource "libvirt_volume" "lib-containerd" {
  name   = "${var.name}_storage.${var.volume_format}"
  pool   = var.pool /// Put this in different pool
  format = "qcow2"
  size   = pow(1024, 3) * 100
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.yml")
}

data "template_file" "meta_data" {
  template = file("${path.module}/templates/meta-data.yml")
  vars     = {
    hostname = var.name
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/templates/network-config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.name}_init.iso"
  pool           = var.pool
  meta_data      = data.template_file.meta_data.rendered
  network_config = data.template_file.network_config.rendered
  user_data      = data.template_file.user_data.rendered
}


resource "libvirt_domain" "vm" {
  name       = var.name
  memory     = var.memory
  vcpu       = var.vcpu
  autostart  = true
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      macvtap = network_interface.value
    }
  }

  disk {
    volume_id = libvirt_volume.volume.id
    scsi      = true
  }

  disk {
    volume_id = libvirt_volume.lib-containerd.id
    scsi      = true
  }

  dynamic "disk" {
    for_each = var.sub_role == "master" ? [libvirt_volume.etcd[0].id] : []
    content {
      volume_id = disk.value
      scsi      = true
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

# Output results to console
output "hostnames" {
  value = libvirt_domain.vm.*
}

output "ip" {
  value = libvirt_domain.vm.network_interface
}
