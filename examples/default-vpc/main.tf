
variable "private_key_path" {}
variable "public_key_path" {}

module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

locals {
  keystore_path = "${path.cwd}/../../test/fixtures/keystore-default-vpc"
}

module "registration" {
  source       = "github.com/insight-infrastructure/terraform-aws-icon-registration.git?ref=v0.1.0"
  network_name = "testnet"

  organization_name    = "Insight-CI1"
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

  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path

  instance_type = "i3.large"
  create_sg     = true

  keystore_path     = local.keystore_path
  keystore_password = "testing1."
  playbook_vars = {
    sync_db = true
  }
}
