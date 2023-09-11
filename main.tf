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
      version = ">= 0.7.0"
    }
  }
}

provider "libvirt" {
  alias = "host-01"
  uri = "qemu+ssh://root@hypervisor/system?keyfile=/root/.ssh/id_ed25519"
}

module "kubernetes-worker-01" {
  source        = "./modules/kubernetes"
  vm_name       = "k8s-vm-worker"
  pool          = "kubernetes-vm"
  interfaces    = var.interfaces
  volume_uri    = var.volume_uri
  volume_format = var.volume_format
  system_volume = 100
  providers = {
    libvirt = libvirt.host-01
  }
}

provider "libvirt" {
  alias = "host-02"
  uri = "qemu+ssh://root@ncn-h002.mtl/system?keyfile=/root/.ssh/id_ed25519"
}

module "kubernetes-worker-02" {
  source        = "./modules/kubernetes"
  vm_name       = "k8s-vm-worker"
  pool          = "kubernetes-vm"
  interfaces    = var.interfaces
  volume_uri    = var.volume_uri
  volume_format = var.volume_format
  system_volume = 100
  providers = {
    libvirt = libvirt.host-02
  }
}

provider "libvirt" {
  alias = "host-03"
  uri = "qemu+ssh://root@ncn-h003.mtl/system?keyfile=/root/.ssh/id_ed25519"
}

module "kubernetes-worker-03" {
  source        = "./modules/kubernetes"
  vm_name       = "k8s-vm-worker"
  pool          = "kubernetes-vm"
  interfaces    = var.interfaces
  volume_uri    = var.volume_uri
  volume_format = var.volume_format
  system_volume = 100
  providers = {
    libvirt = libvirt.host-03
  }
}
