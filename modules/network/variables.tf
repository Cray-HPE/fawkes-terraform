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

variable "name" {
  description = "Name of the network"
  type        = string
  default     = "mypool"
}

variable "autostart" {
  description = "If the network should start with the system"
  type        = bool
  default     = true
}

variable "mode" {
  description = "The network mode"
  type        = string
  default     = "nat"
}

variable "addresses" {
  description = "Address available for the network"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "dns_enabled" {
  description = "If DNS is enabled on the network"
  type        = bool
  default     = true
}

variable "dns_local_only" {
  description = "If DNS is local only on the network"
  type        = bool
  default     = true
}

variable "dhcp4" {
  description = "If DHCP4 is enabled on the network"
  type        = bool
  default     = true
}

variable "dhcp6" {
  description = "If DHCP6 is enabled on the network"
  type        = bool
  default     = false
}

variable "mtu" {
  default = null
}