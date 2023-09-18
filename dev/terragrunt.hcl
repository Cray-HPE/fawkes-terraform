locals {
  nodes = {
    h001 = {
      uri = "qemu:///system",
      interfaces = ["eth0"]
    },
  }
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}
%{ for node_name, node_attrs in local.nodes ~}
provider "libvirt" {
  alias = "${node_name}"
  uri = "${node_attrs.uri}"
}
%{ endfor ~}

%{ for node_name, node_attrs in local.nodes ~}
module "${node_name}_pool" {
  source = "../modules/storage_pool"
  name = "${node_name}_images"
  providers = {
    libvirt = libvirt.${node_name}
  }
}
%{ endfor ~}

%{ for node_name, node_attrs in local.nodes ~}
module "${node_name}_worker" {
  source        = "../modules/kubernetes"
  name       = "k8s-vm-worker-${node_name}"
  pool          = module.${node_name}_pool.pool
  interfaces    = ["eth0"]
  source_image    = "/vms/images/kubernetes-vm-x86_64.qcow2"
  size = 100
  providers = {
    libvirt = libvirt.${node_name}
  }
}
module "${node_name}_master" {
  source        = "../modules/kubernetes"
  name       = "k8s-vm-master-${node_name}"
  pool          = module.${node_name}_pool.pool
  interfaces    = ["eth0"]
  source_image    = "/vms/images/kubernetes-vm-x86_64.qcow2"
  size = 100
  providers = {
    libvirt = libvirt.${node_name}
  }
}
%{ endfor ~}
EOF
}
