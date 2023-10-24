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

| Name                                                                                                     | Type     |
|----------------------------------------------------------------------------------------------------------|----------|
| [libvirt_pool.pool](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.1/docs/resources/pool) | resource |

## Inputs

| Name                                                                  | Description       | Type     | Default        | Required |
|-----------------------------------------------------------------------|-------------------|----------|----------------|:--------:|
| <a name="input_libvirt_uri"></a> [libvirt\_uri](#input\_libvirt\_uri) | QEMU System URI   | `string` | n/a            |   yes    |
| <a name="input_name"></a> [name](#input\_name)                        | Name of the pool. | `string` | `"kubernetes"` |    no    |

## Outputs

| Name                                             | Description |
|--------------------------------------------------|-------------|
| <a name="output_pool"></a> [pool](#output\_pool) | n/a         |
