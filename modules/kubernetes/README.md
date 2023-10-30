## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.7.1 |

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
| <a name="input_base_volume"></a> [base\_volume](#input\_base\_volume) | n/a | `map` | <pre>{<br>  "arch": "x86_64",<br>  "format": "qcow2",<br>  "name": "kubernetes-vm",<br>  "uri": "/vms/images"<br>}</pre> | no |
| <a name="input_default_volume_size"></a> [default\_volume\_size](#input\_default\_volume\_size) | Volume size in GB | `number` | `21` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Create special resources for development environments | `string` | `"dev"` | no |
| <a name="input_hypervisor_name"></a> [hypervisor\_name](#input\_hypervisor\_name) | n/a | `string` | n/a | yes |
| <a name="input_local_networks"></a> [local\_networks](#input\_local\_networks) | A list of local networks to add to the VM. This is used for development. | `any` | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory in MB | `string` | `"4096"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the VM | `string` | `"kubernetes"` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | List of host interfaces that will the VM will receive a macvtap interface for | `list(map(string))` | `[]` | no |
| <a name="input_pci_devices"></a> [pci\_devices](#input\_pci\_devices) | List of all the PCI devices that will be passed to the VM | `list(any)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | `"kubernetes"` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | List of roles for the VM | `list(string)` | <pre>[<br>  "worker"<br>]</pre> | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | n/a | `list(string)` | `[]` | no |
| <a name="input_vcpu"></a> [vcpu](#input\_vcpu) | Number of vCPUs | `number` | `2` | no |
| <a name="input_volume_format"></a> [volume\_format](#input\_volume\_format) | Format of the volume | `string` | `"qcow2"` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | List of volumes for the VM | `any` | n/a | yes |

## Outputs

No outputs.
