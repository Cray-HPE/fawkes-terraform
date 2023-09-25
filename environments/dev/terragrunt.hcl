locals {
  env_name = basename(get_terragrunt_dir())
  inventory = jsondecode(file("inventory.json"))
}

inputs = {
  volume_arch = local.inventory.node_defaults.volume_arch
  volume_format = local.inventory.node_defaults.volume_format
  volume_uri = local.inventory.node_defaults.volume_uri
}

terraform {
  source = "git::https://github.com/Cray-HPE/fawkes-terraform-modules.git//kubernetes?ref=devtest"
}
