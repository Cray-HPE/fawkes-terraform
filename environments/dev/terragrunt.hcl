locals {
  env_name      = basename(get_terragrunt_dir())
  inventory     = jsondecode(file("${get_terragrunt_dir()}/inventory.json"))
  node_defaults = local.inventory.node_defaults
  nodes         = { for k, v in local.inventory.nodes : k => merge(local.inventory.node_defaults, v) }
  globals       = local.inventory.globals
}

include {
  path = find_in_parent_folders()
}

# inputs = {
#   volume_arch   = local.inventory.node_defaults.volume_arch
#   volume_format = local.inventory.node_defaults.volume_format
#   volume_uri    = local.inventory.node_defaults.volume_uri
# }

# terraform {
#   source = "git::https://github.com/Cray-HPE/fawkes-terraform-modules.git//kubernetes?ref=devtest"
# }
