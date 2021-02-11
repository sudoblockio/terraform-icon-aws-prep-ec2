variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

variable "private_key_path" {}
variable "public_key_path" {}
variable "network_name" {
  default = "zicon"
}

module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

locals {
  keystore_path = "${path.cwd}/keystore-default-vpc"
}

module "registration" {
  source       = "github.com/insight-infrastructure/terraform-aws-icon-registration.git"
  network_name = var.network_name
  enable_testing = true
  organization_name    = "Insight-CI-6"
  organization_country = "USA"
  organization_email   = "fake@gmail.com"
  organization_city    = "CircleCI"
  organization_website = "https://google.com"
  keystore_password = "testing1."
  keystore_path     = local.keystore_path
}

resource "random_pet" "this" {length = 2}

module "defaults" {
  source = "../.."
  name = random_pet.this.id
  public_ip = module.registration.public_ip
  network_name = var.network_name
  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path
  instance_type = "t3a.small"
  create_sg     = true
  operator_keystore_path = "${local.keystore_path}-operator"
  operator_keystore_password = module.registration.operator_keystore_password
  playbook_vars = {
    sync_db = true
    enable_update_cron = true
  }
}

output "operator_keystore_path" {
  value = module.registration.operator_keystore_path
}

output "operator_keystore_password" {
  value = module.registration.operator_keystore_password
}

output "public_ip" {
  value = module.registration.public_ip
}

output "instance_public_ip" {
  value = module.defaults.dhcp_ip
}