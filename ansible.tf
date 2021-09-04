

#########
# Ansible
#########
variable "ansible_hardening" {
  description = "Run hardening roles"
  type        = bool
  default     = false
}

variable "cloudwatch_enable" {
  description = "Bool to enable cloudwatch agent. - WIP"
  type        = bool
  default     = false
}

variable "playbook_vars" {
  description = "Additional playbook vars"
  type        = map(string)
  default     = {}
}

variable "keystore_path" {
  description = "The path to the keystore"
  type        = string
  default     = ""
}

variable "keystore_password" {
  description = "The password to the keystore"
  type        = string
  default     = ""
}

variable "operator_keystore_password" {
  description = "the path to your keystore"
  type        = string
  default     = ""
}

variable "operator_keystore_path" {
  description = "The keystore password"
  type        = string
  default     = ""
}

variable "associate_eip" {
  description = "Boolean to determine if you should associate the ip when the instance has been configured"
  type        = bool
  default     = false
}

variable "verbose" {
  description = "Verbose ansible run"
  type        = bool
  default     = false
}

variable "endpoint_url" {
  description = "API endpoint to sync off of - can be citizen node or leave blank for solidwallet.io"
  type        = string
  default     = ""
}

variable "fastest_start" {
  description = "Fast sync option."
  type        = string
  default     = "yes"
}


variable "public_ip" {
  description = "The public IP of the elastic ip to attach to active instance"
  type        = string
  default     = ""
}

variable "bastion_user" {
  description = "Optional bastion user - blank for no bastion"
  type        = string
  default     = ""
}

variable "bastion_ip" {
  description = "Optional IP for bastion - blank for no bastion"
  type        = string
  default     = ""
}

variable "node_type" {
  description = "The type of node, ie prep / citizen. Blank for prep."
  type        = string
  default     = "prep"
}

locals {
  playbook_vars = merge({
    keystore_path          = var.operator_keystore_path == "" ? var.keystore_path : var.operator_keystore_path
    keystore_password      = var.operator_keystore_password == "" ? var.keystore_password : var.operator_keystore_password
    network_name           = var.network_name,
    instance_type          = var.instance_type,
    instance_store_enabled = local.instance_store_enabled,
    node_type              = var.node_type
    endpoint_url           = var.endpoint_url
    cloudwatch_enable      = var.cloudwatch_enable
    this_instance_id       = join("", aws_instance.this.*.id),
    dhcp_ip                = join("", aws_instance.this.*.public_ip),
    ansible_hardening      = var.ansible_hardening,
    fastest_start          = var.fastest_start
  }, var.playbook_vars)
}

resource "aws_eip_association" "main_ip" {
  count       = var.associate_eip && var.create ? 1 : 0
  instance_id = join("", aws_instance.this.*.id)
  public_ip   = var.public_ip
}

module "ansible_associate_eip" {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0"

  create                 = var.associate_eip
  ip                     = join("", aws_eip_association.main_ip.*.public_ip)
  user                   = "ubuntu"
  private_key_path       = pathexpand(var.private_key_path)
  verbose                = var.verbose
  become                 = true
  bastion_ip             = var.bastion_ip
  bastion_user           = var.bastion_user
  playbook_file_path     = "${path.module}/ansible/main.yml"
  playbook_vars          = local.playbook_vars
  requirements_file_path = "${path.module}/ansible/requirements.yml"
}

module "ansible_no_associate_eip" {
  source                 = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0"
  create                 = !var.associate_eip
  ip                     = join("", aws_instance.this.*.public_ip)
  user                   = "ubuntu"
  private_key_path       = pathexpand(var.private_key_path)
  verbose                = var.verbose
  become                 = true
  bastion_ip             = var.bastion_ip
  bastion_user           = var.bastion_user
  playbook_file_path     = "${path.module}/ansible/main.yml"
  playbook_vars          = local.playbook_vars
  requirements_file_path = "${path.module}/ansible/requirements.yml"
}
