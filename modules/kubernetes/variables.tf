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
