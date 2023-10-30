## Requirements

| Name | Version |
|------|---------|
| random | ~>3 |

## Providers

| Name | Version |
|------|---------|
| random | ~>3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_password.luks_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| data\_path | n/a | `string` | `"/"` | no |
| inventory\_path | n/a | `string` | `"inventory"` | no |
| luks\_keys | n/a | `map(string)` | `{}` | no |
| ssh\_keys\_path | n/a | `string` | `"ssh-keys"` | no |

## Outputs

| Name | Description |
|------|-------------|
| globals | n/a |
| hypervisors | n/a |
| ssh\_keys | n/a |