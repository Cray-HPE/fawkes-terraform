## Requirements

| Name | Version |
|------|---------|
| libvirt | 0.7.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| domain | ./kubernetes | n/a |
| network | ../networks | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| data\_path | n/a | `string` | `"/"` | no |
| domains | n/a | `any` | `{}` | no |
| environment | n/a | `string` | `"undef"` | no |
| hypervisor\_name | n/a | `string` | n/a | yes |
| local\_networks | n/a | `any` | `[]` | no |
| luks\_keys | n/a | `map(string)` | `{}` | no |
| prefix | n/a | `string` | `""` | no |

## Outputs

No outputs.