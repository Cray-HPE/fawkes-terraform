terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

# Base OS image
resource "libvirt_volume" "baseosimage" {
  name   = "${var.name}_base_os_image"
  source = var.source_image
  pool   = var.pool
}

# Create a virtual disk per host based on the Base OS Image
resource "libvirt_volume" "volume" {
  name           = "${var.name}.qcow2"
  base_volume_id = libvirt_volume.baseosimage.id
  pool           = var.pool
  format         = "qcow2"
  size           = pow(1024, 3) * var.size
}


data "template_file" "user_data" {
  template = file("${path.module}/cloud-init.cfg")
  vars     = {
    hostname   = var.name
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  pool = var.pool
  name      = "commoninit_${var.name}.iso"
  user_data = data.template_file.user_data.rendered
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
