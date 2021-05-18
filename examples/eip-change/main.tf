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

locals {
  keystore_path = "${path.cwd}/keystore-eip-change"
}

module "registration" {
  source               = "github.com/insight-infrastructure/terraform-aws-icon-registration.git"
  network_name         = "zicon"
  enable_testing       = true
  organization_name    = "Geometry-${random_pet.this.id}"
  organization_country = "USA"
  organization_email   = "fake@gmail.com"
  organization_city    = "CircleCI"
  organization_website = "https://google.com"
  keystore_password    = "testing1."
  keystore_path        = local.keystore_path
}

resource "aws_security_group" "this" {
  vpc_id = module.default_vpc.vpc_id

  dynamic "ingress" {
    for_each = [
      22,   # ssh
      7100, # grpc
      9000, # jsonrpc
      9100, # node exporter
      9113, # nginx exporter - TODO: Needs nginx.conf overview
      9115, # blackbox exporter
      8080, # cadvisor
    ]

    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [
      "0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
}

resource "random_pet" "this" { length = 2 }

module "defaults" {
  source = "../.."

  associate_eip = true

  public_ip                     = module.registration.public_ip
  name                          = random_pet.this.id
  network_name                  = "zicon"
  private_key_path              = var.private_key_path
  public_key_path               = var.public_key_path
  subnet_id                     = module.default_vpc.subnet_ids[0]
  additional_security_group_ids = [aws_security_group.this.id]
  keystore_path                 = local.keystore_path
  keystore_password             = "testing1."
}

output "public_ip" {
  value = module.registration.public_ip
}

output "dhcp_ip" {
  value = module.defaults.public_ip
}
