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
| [libvirt_network.network](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dns\_enabled | If DNS is enabled on the network | `bool` | `true` | no |
| dns\_local\_only | If DNS is local only on the network | `bool` | `true` | no |
| networks | n/a | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |
| name | n/a |
| network | n/a |