## Requirements

| Name | Version |
|------|---------|
| libvirt | 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| libvirt | 0.7.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [libvirt_cloudinit_disk.init](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/cloudinit_disk) | resource |
| [libvirt_domain.vm](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/domain) | resource |
| [libvirt_pool.pool](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/pool) | resource |
| [libvirt_volume.base](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/volume) | resource |
| [libvirt_volume.vol](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| base\_volume | n/a | `map(string)` | <pre>{<br>  "arch": "x86_64",<br>  "format": "qcow2",<br>  "name": "kubernetes-vm",<br>  "uri": "/vms/images"<br>}</pre> | no |
| default\_volume\_size | Volume size in GB | `number` | `21` | no |
| environment | Create special resources for development environments | `string` | `"dev"` | no |
| hypervisor\_name | n/a | `string` | n/a | yes |
| local\_networks | A list of local networks to add to the VM. This is used for development. | `any` | `[]` | no |
| memory | Memory in MB | `string` | `"4096"` | no |
| name | Name of the VM | `string` | `"kubernetes"` | no |
| network\_interfaces | List of host interfaces that will the VM will receive a macvtap interface for | `list(map(string))` | `[]` | no |
| pci\_devices | List of all the PCI devices that will be passed to the VM | `list(any)` | `[]` | no |
| prefix | n/a | `string` | `"kubernetes"` | no |
| roles | List of roles for the VM | `list(string)` | <pre>[<br>  "worker"<br>]</pre> | no |
| ssh\_keys | n/a | `list(string)` | `[]` | no |
| vcpu | Number of vCPUs | `number` | `2` | no |
| volume\_format | Format of the volume | `string` | `"qcow2"` | no |
| volumes | List of volumes for the VM | `any` | n/a | yes |

## Outputs

No outputs.