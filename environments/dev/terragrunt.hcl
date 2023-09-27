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
