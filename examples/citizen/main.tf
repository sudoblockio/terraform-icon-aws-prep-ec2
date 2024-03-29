variable "aws_region" {
  default = "us-east-2"
}

provider "aws" {
  region = var.aws_region
}

variable "private_key_path" {}
variable "public_key_path" {}

module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

resource "random_pet" "this" { length = 2 }

module "defaults" {
  source           = "../.."
  service          = "Sejong"
  name             = "citizen-test-${random_pet.this.id}"
  node_type        = "citizen"
  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path
  key_name         = "citizen-test-${random_pet.this.id}"
  create_sg        = true
  fastest_start    = "no" # ONLY FOR TESTING - Remove / set to "yes" for actual use
}

output "public_ip" {
  value = module.defaults.dhcp_ip
}
