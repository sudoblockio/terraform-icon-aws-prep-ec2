# terraform-icon-aws-prep

This module is a WIP until it is integrated into a `terragrunt` scaffolding.

## Features

This module sets up a node on ICON Blockchain without any networking defaults. For examples on how to use it, see the
`examples` directory. For the simplest and minimal specs, run with the `min_specs = true` variable.

The module sets up an instance with several options for how to store the data. One can one large root volume (min specs),
attach an EBS volume, or use the attached instance storage for the highest performance.

Further integrations with monitoring, logging and alarms with permissioned instance profiles are being developed.

The module calls [ansible-role-icon-prep](https://github.com/insight-infrastructure/ansible-role-icon-prep) from within
the module and exposed configuration settings as terraform variables.

## Terraform Versions

For Terraform v0.12.0+

## Usage

*Minimum specs : simplest example*
```terraform
module "defaults" {
  source = "github.com/insight-infrastructure/terraform-icon-aws-prep.git?ref=master"

  minimum_specs = true

  public_ip = module.registration.public_ip

  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path

  subnet_id              = module.default_vpc.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.this.id]

  keystore_path     = local.keystore_path
  keystore_password = "testing1."
}
```

## Examples

- [min-specs](https://github.com/robc-io/terraform-icon-aws-prep/tree/master/examples/min-specs)
- [instance-store](https://github.com/robc-io/terraform-icon-aws-prep/tree/master/examples/instance-store)

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
| additional\_security\_group\_ids | List of security groups | `list(string)` | `[]` | no |
| ansible\_hardening | Run hardening roles | `bool` | `false` | no |
| associate\_eip | Boolean to determine if you should associate the ip when the instance has been configured | `bool` | `true` | no |
| create | Boolean to create resources or not | `bool` | `true` | no |
| create\_ebs\_volume | #### EBS #### | `bool` | `false` | no |
| create\_sg | Bool for create security group | `bool` | `false` | no |
| instance\_type | Instance type | `string` | `"t3.small"` | no |
| key\_name | The key pair to import - leave blank to generate new keypair from pub/priv ssh key path | `string` | `""` | no |
| keystore\_password | The password to the keystore | `string` | `""` | no |
| keystore\_path | The path to the keystore | `string` | `""` | no |
| logging\_bucket\_name | Name of bucket for logs - blank for logs-<account-id> | `string` | `""` | no |
| logs\_bucket\_enable | Create bucket to put logs | `bool` | `false` | no |
| monitoring | Boolean for cloudwatch | `bool` | `false` | no |
| name | The name for the label | `string` | `"prep"` | no |
| network\_name | The network name, ie kusama / mainnet | `string` | n/a | yes |
| operator\_keystore\_password | the path to your keystore | `string` | `""` | no |
| operator\_keystore\_path | The keystore password | `string` | `""` | no |
| playbook\_vars | Additional playbook vars | `map(string)` | `{}` | no |
| private\_key\_path | The path to the private ssh key | `string` | n/a | yes |
| private\_port\_cidrs | List of CIDR blocks for private ports | `list(string)` | <pre>[<br>  "172.31.0.0/16"<br>]</pre> | no |
| private\_ports | List of publicly open ports | `list(number)` | <pre>[<br>  9100,<br>  9113,<br>  9115,<br>  8080<br>]</pre> | no |
| public\_ip | The public IP of the elastic ip to attach to active instance | `string` | `""` | no |
| public\_key\_path | The path to the public ssh key | `string` | n/a | yes |
| public\_ports | List of publicly open ports | `list(number)` | <pre>[<br>  22,<br>  7100,<br>  9000,<br>  9100,<br>  9113,<br>  9115,<br>  8080<br>]</pre> | no |
| root\_iops | n/a | `string` | n/a | yes |
| root\_volume\_size | Root volume size | `number` | `8` | no |
| root\_volume\_type | n/a | `string` | `"gp2"` | no |
| subnet\_id | The id of the subnet | `string` | `""` | no |
| switch\_ip\_internally | Bool to switch ip internally | `bool` | `true` | no |
| tags | Map of tags | `map(string)` | `{}` | no |
| volume\_path | The path of the EBS volume | `string` | `"/dev/xvdf"` | no |
| vpc\_id | Custom vpc id - leave blank for deault | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| dhcp\_ip | n/a |
| ebs\_volume\_arn | n/a |
| instance\_id | n/a |
| instance\_store\_enabled | n/a |
| instance\_type | n/a |
| key\_name | n/a |
| network\_name | n/a |
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