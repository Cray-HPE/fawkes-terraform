locals {
  env_name = basename(get_terragrunt_dir())
}

include {
  path = find_in_parent_folders()
}
