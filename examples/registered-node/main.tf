variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

variable "private_key_path" {}
variable "public_key_path" {}
variable "public_ip" {}
variable "network_name" {
  description = "Options - 'mainnet', 'zicon', 'bicon', 'testnet'."
}
variable "node_name" {}
variable "keystore_path" {}
variable "keystore_password" {}


module "default_vpc" {
  source = "github.com/insight-infrastructure/terraform-aws-default-vpc.git?ref=v0.1.0"
}

resource "aws_security_group" "this" {
  vpc_id = module.default_vpc.vpc_id

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

module "defaults" {
  source = "../.."

  associate_eip = true

  public_ip                     = var.public_ip
  name                          = var.node_name
  network_name                  = var.network_name
  private_key_path              = var.private_key_path
  public_key_path               = var.public_key_path
  subnet_id                     = module.default_vpc.subnet_ids[0]
  additional_security_group_ids = [aws_security_group.this.id]
  keystore_path                 = var.keystore_path
  keystore_password             = var.keystore_password
}

output "public_ip" {
  value = module.defaults.public_ip
}
