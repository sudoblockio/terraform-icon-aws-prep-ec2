# terraform-icon-aws-prep-ec2

## Features

This module sets up a ICON Blockchain 2.0 node without any networking defaults. For examples on how to use it, see the `examples` directory. For the simplest and minimal specs, run with the `min_specs = true` variable.

The module sets up an instance with several options for how to store the data. One can one large root volume or use the attached instance storage for the highest performance.

The module calls [ansible-role-icon-prep](https://github.com/geometry-infra/ansible-role-icon-prep) from within the module and exposed configuration settings as terraform variables.

## Terraform Versions

For Terraform v0.12.0+

## Usage

#### Using Example 

After installing the prerequisites:

- If your node is already registered
```shell script
cd examples/registered-node
terraform init
terraform apply 
```

- If your node is not already registered

*Modify the example per the network and registration as fit / contact Geometry Labs for help.*


#### Terraform Module 

*Minimum specs : simplest example*
```terraform
module "defaults" {
  source = "github.com/geometry-infra/terraform-icon-aws-prep-ec2.git?ref=master"

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

- [min-specs](https://github.com/geometry-infra/terraform-icon-aws-prep-ec2/tree/master/examples/min-specs)
- [instance-store](https://github.com/geometry-infra/terraform-icon-aws-prep-ec2/tree/master/examples/instance-store)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ami | github.com/insight-infrastructure/terraform-aws-ami.git?ref=v0.1.0 |  |
| ansible_associate_eip | github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0 |  |
| ansible_no_associate_eip | github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0 |  |

## Resources

| Name |
|------|
| [aws_eip_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_group\_ids | List of security groups | `list(string)` | `[]` | no |
| ansible\_hardening | Run hardening roles | `bool` | `false` | no |
| associate\_eip | Boolean to determine if you should associate the ip when the instance has been configured | `bool` | `false` | no |
| bastion\_ip | Optional IP for bastion - blank for no bastion | `string` | `""` | no |
| bastion\_user | Optional bastion user - blank for no bastion | `string` | `""` | no |
| cloudwatch\_enable | Bool to enable cloudwatch agent. - WIP | `bool` | `false` | no |
| create | Boolean to create resources or not | `bool` | `true` | no |
| create\_sg | Bool for create security group | `bool` | `true` | no |
| endpoint\_url | API endpoint to sync off of - can be citizen node or leave blank for solidwallet.io | `string` | `""` | no |
| fastest\_start | Fast sync option. | `string` | `"yes"` | no |
| iam\_instance\_profile\_id | Instance profile ID | `string` | `null` | no |
| instance\_type | Instance type | `string` | `"t3.small"` | no |
| key\_name | The key pair to import - leave blank to generate new keypair from pub/priv ssh key path | `string` | `""` | no |
| key\_pair\_name | Defaults to basename ssh key | `string` | `""` | no |
| keystore\_password | The password to the keystore | `string` | `""` | no |
| keystore\_path | The path to the keystore | `string` | `""` | no |
| minimum\_volume\_size\_map | Map for networks with min volume size | `map(string)` | <pre>{<br>  "bicon": 150,<br>  "mainnet": 500,<br>  "sejong": 50,<br>  "testnet": 150,<br>  "zicon": 150<br>}</pre> | no |
| monitoring | Boolean for cloudwatch | `bool` | `false` | no |
| name | The name for the label | `string` | `"prep"` | no |
| network\_name | The network name, ie mainnet, zicon, bicon, testnet | `string` | n/a | yes |
| node\_type | The type of node, ie prep / citizen. Blank for prep. | `string` | `"prep"` | no |
| operator\_keystore\_password | the path to your keystore | `string` | `""` | no |
| operator\_keystore\_path | The keystore password | `string` | `""` | no |
| playbook\_vars | Additional playbook vars | `map(string)` | `{}` | no |
| private\_key\_path | The path to the private ssh key | `string` | n/a | yes |
| public\_ip | The public IP of the elastic ip to attach to active instance | `string` | `""` | no |
| public\_key\_path | The path to the public ssh key | `string` | n/a | yes |
| public\_ports | List of publicly open ports | `list(number)` | <pre>[<br>  22,<br>  9080,<br>  8080<br>]</pre> | no |
| root\_iops | n/a | `string` | `null` | no |
| root\_volume\_size | Root volume size | `number` | `20` | no |
| root\_volume\_type | n/a | `string` | `"gp2"` | no |
| subnet\_id | The id of the subnet | `string` | `""` | no |
| tags | Map of tags | `map(string)` | `{}` | no |
| verbose | Verbose ansible run | `bool` | `false` | no |
| vpc\_id | Custom vpc id - leave blank for deault | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| dhcp\_ip | n/a |
| instance\_id | n/a |
| instance\_store\_enabled | n/a |
| instance\_type | n/a |
| key\_name | n/a |
| network\_name | n/a |
| public\_ip | n/a |
| security\_group\_id | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

> Note: There is a bug where the registration module runs on a destroy, thus you can't run all the tests in the tests directory as they will fail on destroy leaving idle resources.  

To run them normally:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## Authors

Module managed by Geometry Labs and [robcxyz](github.com/robcxyz). 

## License

Apache 2 Licensed. See LICENSE for full details.