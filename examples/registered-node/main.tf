variable "aws_region" {}

provider "aws" {
  region = var.aws_region
}

variable "vpc_id" {}
variable "private_key_path" {}
variable "public_key_path" {}

resource "aws_eip" "test" {}

variable "node_name" {}
#variable "keystore_path" {}
#variable "keystore_password" {}


module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

resource "aws_security_group" "this" {
  #  vpc_id = module.default_vpc.vpc_id

  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = [
      22,   # ssh
      7100, # grpc
      9000, # jsonrpc
      //      9100, # node exporter
      //      9113, # nginx exporter - TODO: Needs nginx.conf overview
      //      9115, # blackbox exporter
      //      8080, # cadvisor
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

variable "subnet_id" {}

module "defaults" {
  source = "../.."

  name                          = var.node_name
  service                       = "Sejong"
  private_key_path              = var.private_key_path
  public_key_path               = var.public_key_path
  subnet_id                     = var.subnet_id #  module.default_vpc.subnet_ids[0]
  additional_security_group_ids = [aws_security_group.this.id]

  create_sg = false

  keystore_path     = "${path.cwd}/keystore"
  keystore_password = "foobar"
  #  keystore_path                 = var.keystore_path
  #  keystore_password             = var.keystore_password

  fastest_start = "no" # ONLY FOR TESTING - Remove / set to "yes" for actual use
}
