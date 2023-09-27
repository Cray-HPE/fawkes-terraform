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
variable "volume_arch" {
  description = "Architecture of the image"
  type        = string
}

variable "volume_format" {
  description = "Format of the volume"
  type        = string
}

variable "volume_uri" {
  description = "URI to volumes (without the file extension)"
  type        = string
}

variable "volume_size" {
  description = "Volume size in GB"
  type        = number
  default     = 20
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

variable "pool" {
  description = "Name of pool for volumes"
  type        = string
  default     = "default"
}

variable "interfaces" {
  description = "List of host interfaces that will the VM will receive a macvtap interface for"
  type        = list(string)
  default = ["eth0"]
}

variable "libvirt_uri" {
  description = "QEMU System URI"
  type        = string
  default = "qemu:///system"
}

variable "master" {
  type = bool
  default = true
}
