terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

variable "name" {
  type = string
  default = "mypool"
}

resource "libvirt_pool" "pool" {
  name = var.name
  type = "dir"
  path = "/var/lib/libvirt/${var.name}"
}

output "pool" {
  value = libvirt_pool.pool.name
}
