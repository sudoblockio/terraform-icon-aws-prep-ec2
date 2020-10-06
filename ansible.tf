

#########
# Ansible
#########
variable "ansible_hardening" {
  description = "Run hardening roles"
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

// TODO
variable "switch_ip_internally" {
  description = "Bool to switch ip internally"
  type        = bool
  default     = false
}

variable "endpoint_url" {
  description = "API endpoint to sync off of - can be citizen node or leave blank for solidwallet.io"
  type        = string
  default     = ""
}

variable "public_ip" {
  description = "The public IP of the elastic ip to attach to active instance"
  type        = string
  default     = ""
}



//variable "private_key_path" {
//  description = "Path to the private ssh key"
//  type        = string
//  default     = ""
//}
//
//variable "playbook_file_path" {
//  description = "The path to the playbook"
//  type        = string
//  default     = ""
//}
//
//variable "user" {
//  description = "The user for configuring node with ansible"
//  type        = string
//  default     = "ubuntu"
//}


module "ansible" {
  source           = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.14.0"
  create           = var.create
  ip               = join("", aws_instance.this.*.public_ip)
  user             = "ubuntu"
  private_key_path = pathexpand(var.private_key_path)

  playbook_file_path = "${path.module}/ansible/main.yml"
  playbook_vars = merge({
    keystore_path          = var.operator_keystore_path == "" ? var.keystore_path : var.operator_keystore_path
    keystore_password      = var.operator_keystore_password == "" ? var.keystore_password : var.operator_keystore_password
    network_name           = var.network_name,
    instance_type          = var.instance_type,
    instance_store_enabled = local.instance_store_enabled,
    main_ip                = var.public_ip,

    endpoint_url = var.endpoint_url

    cloudwatch_enable = var.cloudwatch_enable

    switch_ip_internally = var.switch_ip_internally

    this_instance_id  = join("", aws_instance.this.*.id),
    dhcp_ip           = join("", aws_instance.this.*.public_ip),
    ansible_hardening = var.ansible_hardening,
  }, var.playbook_vars)

  requirements_file_path = "${path.module}/ansible/requirements.yml"
}

//data "aws_eip" "public_ip" {
//  count     = var.public_ip == "" ? 0 : 1
//  public_ip = var.public_ip
//}
//
//resource "aws_eip_association" "main_ip" {
//  count       = var.public_ip != "" && var.associate_eip && var.create ? 1 : 0
//  instance_id = join("", aws_instance.this.*.id)
//  public_ip   = join("", data.aws_eip.public_ip.*.public_ip)
//
//  depends_on = [module.ansible]
//}

//module "ansible_service_start" {
//  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.12.0"
//  create = var.public_ip != "" && var.associate_eip && var.create
//
//  ip               = join("", aws_eip_association.main_ip.*.public_ip)
//  user             = "ubuntu"
//  private_key_path = var.private_key_path
//
//  tags = "service-start"
//
//  playbook_file_path = "${path.module}/ansible/main.yml"
//
//  module_depends_on = [join("", aws_eip_association.main_ip.*.id), module.ansible.ip]
//}
