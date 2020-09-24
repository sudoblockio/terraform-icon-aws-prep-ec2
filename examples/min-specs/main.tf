
variable "private_key_path" {}
variable "public_key_path" {}

module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

locals {
  keystore_path = "${path.cwd}/../../test/fixtures/keystore-min-specs"
}

module "registration" {
  source       = "github.com/insight-infrastructure/terraform-aws-icon-registration.git?ref=v0.1.0"
  network_name = "zicon"

  organization_name    = "Insight-CI1"
  organization_country = "USA"
  organization_email   = "fake@gmail.com"
  organization_city    = "CircleCI"
  organization_website = "https://google.com"

  keystore_password = "testing1."
  keystore_path     = local.keystore_path
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

module "defaults" {
  source = "../.."

  minimum_specs = true

  public_ip = module.registration.public_ip

  private_key_path = var.private_key_path
  public_key_path  = var.public_key_path

  subnet_id                     = module.default_vpc.subnet_ids[0]
  additional_security_group_ids = [aws_security_group.this.id]

  keystore_path     = local.keystore_path
  keystore_password = "testing1."
}
