locals {
  env_name = basename(get_terragrunt_dir())
}

include {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/"
}
