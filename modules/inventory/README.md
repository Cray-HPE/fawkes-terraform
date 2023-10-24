## Requirements

| Name                                                             | Version |
|------------------------------------------------------------------|---------|
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3     |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~>3     |

## Modules

No modules.

## Resources

| Name                                                                                                                | Type     |
|---------------------------------------------------------------------------------------------------------------------|----------|
| [random_password.luks_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name                                                                           | Description | Type     | Default       | Required |
|--------------------------------------------------------------------------------|-------------|----------|---------------|:--------:|
| <a name="input_data_path"></a> [data\_path](#input\_data\_path)                | n/a         | `string` | `"/"`         |    no    |
| <a name="input_inventory_path"></a> [inventory\_path](#input\_inventory\_path) | n/a         | `string` | `"inventory"` |    no    |
| <a name="input_luks_keys"></a> [luks\_keys](#input\_luks\_keys)                | n/a         | `map`    | `{}`          |    no    |
| <a name="input_ssh_keys_path"></a> [ssh\_keys\_path](#input\_ssh\_keys\_path)  | n/a         | `string` | `"ssh-keys"`  |    no    |

## Outputs

| Name                                                                  | Description |
|-----------------------------------------------------------------------|-------------|
| <a name="output_globals"></a> [globals](#output\_globals)             | n/a         |
| <a name="output_hypervisors"></a> [hypervisors](#output\_hypervisors) | n/a         |
| <a name="output_ssh_keys"></a> [ssh\_keys](#output\_ssh\_keys)        | n/a         |
