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

variable "volumes" {
  description = "List of volumes for the VM"
  type        = any
}

variable "roles" {
  description = "List of roles for the VM"
  type        = list(string)
  default     = ["worker"]
}

variable "volume_format" {
  description = "Format of the volume"
  type        = string
  default     = "qcow2"
}

variable "base_volume" {
  type    = map(string)
  default = {
    name   = "kubernetes-vm"
    uri    = "/vms/images"
    arch   = "x86_64"
    format = "qcow2"
  }
}

variable "default_volume_size" {
  description = "Volume size in GB"
  type        = number
  default     = 21
}

variable "name" {
  description = "Name of the VM"
  type        = string
  default     = "kubernetes"
}

variable "memory" {
  description = "Memory in MB"
  type        = string
  default     = "4096"
}

variable "vcpu" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "local_networks" {
  description = "A list of local networks to add to the VM. This is used for development."
  type        = any
  default     = []
}

variable "network_interfaces" {
  description = "List of host interfaces that will the VM will receive a macvtap interface for"
  type        = list(map(string))
  default     = []
}

variable "environment" {
  description = "Create special resources for development environments"
  type        = string
  default     = "dev"
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}

variable "pci_devices" {
  description = "List of all the PCI devices that will be passed to the VM"
  type        = list(any)
  default     = []
}

variable "hypervisor_name" {
  type = string
}

variable "prefix" {
  type    = string
  default = "kubernetes"
}
