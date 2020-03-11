# terraform-icon-aws-prep

## Features

This module...

## Terraform Versions

For Terraform v0.12.0+

## Usage

```
module "this" {
    source = "github.com/robc-io/terraform-icon-aws-prep"

}
```
## Examples

- [defaults](https://github.com/robc-io/terraform-icon-aws-prep/tree/master/examples/defaults)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ebs\_volume\_id | The volume id of the ebs volume to mount | `string` | `""` | no |
| ebs\_volume\_size | The size of volume - leave as zero or empty for no volume | `number` | `0` | no |
| eip\_id | The elastic ip id to attach to active instance | `string` | `""` | no |
| environment | The environment | `string` | `""` | no |
| instance\_type | Instance type | `string` | `"t2.micro"` | no |
| key\_name | The key pair to import - leave blank to generate new keypair from pub/priv ssh key path | `string` | `""` | no |
| keystore\_password | The password to the keystore | `string` | `""` | no |
| keystore\_path | The path to the keystore | `string` | `""` | no |
| logs\_bucket\_enable | Create bucket to put logs | `bool` | `true` | no |
| monitoring | Boolean for cloudwatch | `bool` | `false` | no |
| name | The name for the label | `string` | `"prep"` | no |
| namespace | The namespace to deploy into | `string` | `"prod"` | no |
| network\_name | The network name, ie kusama / mainnet | `string` | `"testnet"` | no |
| owner | Owner of the infrastructure | `string` | `""` | no |
| playbook\_vars | Additional playbook vars | `map(string)` | `{}` | no |
| private\_key\_path | The path to the private ssh key | `string` | n/a | yes |
| public\_key\_path | The path to the public ssh key | `string` | n/a | yes |
| root\_volume\_size | Root volume size | `string` | `8` | no |
| stage | The stage of the deployment | `string` | `"blue"` | no |
| subnet\_id | The id of the subnet | `string` | n/a | yes |
| volume\_path | The path of the EBS volume | `string` | `"/dev/xvdf"` | no |
| vpc\_security\_group\_ids | List of security groups | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## Authors

Module managed by [robc-io](github.com/robc-io)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.