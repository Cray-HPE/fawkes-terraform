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
  source = "${var.volume_uri}-${var.volume_arch}.${var.volume_format}"
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

# Create a virtual disk for etcd
resource "libvirt_volume" "etcd" {
  count  = var.master ? 1 : 0
  name   = "${var.name}_etcd.qcow2"
  pool   = var.pool /// Put this in different pool
  format = "qcow2"
  size   = pow(1024, 3) * 32
}

# Create a virtual disk for /var/lib/containerd
resource "libvirt_volume" "storage" {
  name   = "${var.name}_storage.qcow2"
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
    hostname   = var.name
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/templates/network-config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "${var.name}_init.iso"
  pool = var.pool
  meta_data      = data.template_file.meta_data.rendered
  network_config = data.template_file.network_config.rendered
  user_data      = data.template_file.user_data.rendered
}


resource "libvirt_domain" "vm" {
  name   = var.name
  memory = var.memory
  vcpu   = var.vcpu
  autostart = true
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
    scsi = true
    wwn = "05abcd285c6230c1"
  }

  disk {
    volume_id = libvirt_volume.storage.id
    scsi = true
    wwn = "05abcd285c6230c2"
  }

  dynamic "disk" {
    for_each = var.master ? [libvirt_volume.etcd[0].id] : []
    content {
      volume_id = disk.value
      scsi = true
      wwn = "05abcd285c6230c3"
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
