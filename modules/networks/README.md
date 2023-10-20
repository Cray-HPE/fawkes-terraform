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
| [libvirt_network.network](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_enabled"></a> [dns\_enabled](#input\_dns\_enabled) | If DNS is enabled on the network | `bool` | `true` | no |
| <a name="input_dns_local_only"></a> [dns\_local\_only](#input\_dns\_local\_only) | If DNS is local only on the network | `bool` | `true` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | n/a | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
