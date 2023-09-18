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
module "${node_name}" {
  source        = "../modules/kubernetes"
  name       = "k8s-vm-${node_attrs.type}-${node_name}"
  pool          = "${node_name}_images"
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
