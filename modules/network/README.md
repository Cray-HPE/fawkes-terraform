## Requirements

| Name                                                                | Version |
|---------------------------------------------------------------------|---------|
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.7.1   |

## Providers

| Name                                                          | Version |
|---------------------------------------------------------------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.7.1   |

## Modules

No modules.

## Resources

| Name                                                                                                              | Type     |
|-------------------------------------------------------------------------------------------------------------------|----------|
| [libvirt_network.network](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/network) | resource |

## Inputs

| Name                                                                             | Description                                 | Type           | Default                                 | Required |
|----------------------------------------------------------------------------------|---------------------------------------------|----------------|-----------------------------------------|:--------:|
| <a name="input_addresses"></a> [addresses](#input\_addresses)                    | Address available for the network           | `list(string)` | <pre>[<br>  "192.168.1.0/24"<br>]</pre> |    no    |
| <a name="input_autostart"></a> [autostart](#input\_autostart)                    | If the network should start with the system | `bool`         | `true`                                  |    no    |
| <a name="input_dhcp4"></a> [dhcp4](#input\_dhcp4)                                | If DHCP4 is enabled on the network          | `bool`         | `true`                                  |    no    |
| <a name="input_dhcp6"></a> [dhcp6](#input\_dhcp6)                                | If DHCP6 is enabled on the network          | `bool`         | `false`                                 |    no    |
| <a name="input_dns_enabled"></a> [dns\_enabled](#input\_dns\_enabled)            | If DNS is enabled on the network            | `bool`         | `true`                                  |    no    |
| <a name="input_dns_local_only"></a> [dns\_local\_only](#input\_dns\_local\_only) | If DNS is local only on the network         | `bool`         | `true`                                  |    no    |
| <a name="input_mode"></a> [mode](#input\_mode)                                   | The network mode                            | `string`       | `"nat"`                                 |    no    |
| <a name="input_mtu"></a> [mtu](#input\_mtu)                                      | n/a                                         | `any`          | `null`                                  |    no    |
| <a name="input_name"></a> [name](#input\_name)                                   | Name of the network                         | `string`       | `"mypool"`                              |    no    |

## Outputs

| Name                                                      | Description |
|-----------------------------------------------------------|-------------|
| <a name="output_id"></a> [id](#output\_id)                | n/a         |
| <a name="output_name"></a> [name](#output\_name)          | n/a         |
| <a name="output_network"></a> [network](#output\_network) | n/a         |
