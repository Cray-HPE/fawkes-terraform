variable "data_path" {
  default = "/"
}

variable "ssh_keys_path" {
  default = "ssh-keys"
}

variable "inventory_path" {
  default = "inventory"
}

variable "luks_keys" {
  type = map
  default = {}
}