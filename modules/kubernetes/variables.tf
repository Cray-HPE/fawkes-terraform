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
### OPTIONALS
variable "interfaces" {
  default     = ["eth0"]
  description = "List of host interfaces that will the VM will receive a macvtap interface for"
  type        = list(string)
}

variable "memory" {
  default     = "4096"
  description = "Memory in MB"
  type        = string
}

variable "name" {
  default     = "kubernetes"
  description = "Name of the VM"
  type        = string
}

variable "pool" {
  default     = "default"
  description = "Name of pool for volumes"
  type        = string
}

variable "vcpu" {
  default     = 2
  description = "Number of vCPUs"
  type        = number
}

variable "volume_arch" {
  default     = "x86_64"
  description = "Architecture of the image"
  type        = string
}

variable "volume_format" {
  default     = "qcow2"
  description = "Format of the volume"
  type        = string
}

variable "volume_name" {
  default     = "kubernetes-vm"
  description = "URI to volumes (without the file extension or architecture)."
  type        = string
}

variable "volume_size" {
  description = "Volume size in GB"
  type        = number
  default     = 20
}

### REQUIRED
variable "sub_role" {
  description = "The sub-role (master or worker) that this module is playing."
  type        = string
}

variable "volume_uri" {
  description = "URI to volume (without the filename)."
  type        = string
}
