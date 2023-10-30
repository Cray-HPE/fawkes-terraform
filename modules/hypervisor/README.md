## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.7.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_domain"></a> [domain](#module\_domain) | ./kubernetes | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./networks | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_path"></a> [data\_path](#input\_data\_path) | n/a | `string` | `"/"` | no |
| <a name="input_domains"></a> [domains](#input\_domains) | n/a | `any` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"undef"` | no |
| <a name="input_hypervisor_name"></a> [hypervisor\_name](#input\_hypervisor\_name) | n/a | `string` | n/a | yes |
| <a name="input_local_networks"></a> [local\_networks](#input\_local\_networks) | n/a | `any` | `[]` | no |
| <a name="input_luks_keys"></a> [luks\_keys](#input\_luks\_keys) | n/a | `map(string)` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | `""` | no |

## Outputs

No outputs.
