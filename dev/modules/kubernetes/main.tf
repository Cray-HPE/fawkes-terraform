terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

variable "project_name" {
  type = string
  default = "myproject"
}

variable "name" {
  type = string
  default = "myvm"
}

variable "vcpu" {
  type = string
  default = "1"
}

variable "memory" {
  type = string
  default = "1024"
}

variable "size" {
  type = string
  default = "100"
}

variable "pool" {
  type = string
}

variable "interfaces" {
  type = list(string)
  default = ["eth0"]
}

variable "source_image" {
  type    = string
  default = "/vms/images/kubernetes-vm-x86_64.qcow2"
}

# Base OS image
resource "libvirt_volume" "baseosimage" {
  name   = "${var.project_name}_base_os_image"
  source = var.source_image
  pool   = var.pool
  depends_on = [var.pool]
}

# Create a virtual disk per host based on the Base OS Image
resource "libvirt_volume" "qcow2_volume" {
  name           = "${var.name}.qcow2"
  base_volume_id = libvirt_volume.baseosimage.id
  pool           = var.pool
  format         = "qcow2"
  size           = pow(1024, 3) * var.size
  depends_on = [var.pool]
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


resource "libvirt_domain" "kubernetes_vm" {
  name   = var.name
  memory = var.memory
  vcpu   = var.vcpu

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      macvtap = network_interface.value
    }
  }

  disk {
    volume_id = libvirt_volume.qcow2_volume.id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id
}

# Output results to console
output "hostnames" {
  value = libvirt_domain.kubernetes_vm.*
}
