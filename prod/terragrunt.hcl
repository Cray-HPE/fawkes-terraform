locals {
  nodes = {
    h001 = {
      uri = "qemu:///system",
      interfaces = ["eth0"],
      type = "master"
    },
    h002 = {
      uri = "qemu:///system",
      interfaces = ["eth0"],
      type = "worker"
    },
    h003 = {
      uri = "qemu:///system",
      interfaces = ["eth0"],
      type = "worker"
    },
  }
}
#interfaces = ["bond0.nmn0", "bond0.hmn0", "bond0.cmn0"]
#volume_uri = "http://bootserver/nexus/repository/os-images/kubernetes-vm"

generate "versions" {
  path = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}
EOF
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
%{ for node_name, node_attrs in local.nodes ~}
provider "libvirt" {
  alias = "${node_name}"
  uri = "${node_attrs.uri}"
}
%{ endfor ~}
EOF
}

generate "storage" {
  path = "storage.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
%{ for node_name, node_attrs in local.nodes ~}
module "${node_name}_pool" {
  source = "../modules/storage_pool"
  name = "${node_name}_images"
  providers = {
    libvirt = libvirt.${node_name}
  }
}
%{ endfor ~}
EOF
}

generate "main" {
  path = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
%{ for node_name, node_attrs in local.nodes ~}
module "${node_name}" {
  source        = "../modules/kubernetes"
  name       = "k8s-vm-${node_attrs.type}-${node_name}"
  pool          = module.${node_name}_pool.pool
  interfaces    = ["eth0"]
  source_image    = "/vms/images/kubernetes-vm-x86_64.qcow2"
  size = 100
#  type = ${node_attrs.type}
  providers = {
    libvirt = libvirt.${node_name}
  }
}
%{ endfor ~}
EOF
}
