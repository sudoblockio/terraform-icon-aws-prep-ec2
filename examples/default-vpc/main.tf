
variable "private_key_path" {}
variable "public_key_path" {}
variable "network_name" {
  default = "zicon"
}

module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

locals {
  keystore_path = "${path.module}/../../test/fixtures/keystore-default-vpc"
}

module "registration" {
  source       = "github.com/insight-infrastructure/terraform-aws-icon-registration.git"
  network_name = var.network_name

  enable_testing = true


  organization_name    = "Insight-CI-default-vpc"
  organization_country = "USA"
  organization_email   = "fake@gmail.com"
  organization_city    = "CircleCI"
  organization_website = "https://google.com"

  keystore_password = "testing1."
  keystore_path     = local.keystore_path
}

module "defaults" {
  source = "../.."

  public_ip = module.registration.public_ip

  network_name = var.network_name

  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path

  instance_type = "i3.large"
  create_sg     = true

  operator_keystore_path     = module.registration.operator_wallet_path
  operator_keystore_password = module.registration.operator_password
  playbook_vars = {
    sync_db = true
  }
}
