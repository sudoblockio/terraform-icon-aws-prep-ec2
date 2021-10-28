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

variable "role_number" {
  description = "0 for citizen 3 for prep"
  default     = 3
  type        = number
}

variable "mig_endpoint" {
  description = "icon 1.0 endpoint"
  default     = ""
}

locals {
  playbook_vars = merge({
    keystore_path     = var.keystore_path
    keystore_password = var.keystore_password

    role_number  = var.role_number
    mig_endpoint = var.mig_endpoint

    service = var.service,

    instance_type          = var.instance_type,
    instance_store_enabled = local.instance_store_enabled,
  }, var.playbook_vars)
}

module "ansible" {
  source                 = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0"
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
