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
| addresses | Address available for the network | `list(string)` | <pre>[<br>  "192.168.1.0/24"<br>]</pre> | no |
| autostart | If the network should start with the system | `bool` | `true` | no |
| dhcp4 | If DHCP4 is enabled on the network | `bool` | `true` | no |
| dhcp6 | If DHCP6 is enabled on the network | `bool` | `false` | no |
| dns\_enabled | If DNS is enabled on the network | `bool` | `true` | no |
| dns\_local\_only | If DNS is local only on the network | `bool` | `true` | no |
| mode | The network mode | `string` | `"nat"` | no |
| mtu | n/a | `any` | `null` | no |
| name | Name of the network | `string` | `"mypool"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |
| name | n/a |
| network | n/a |