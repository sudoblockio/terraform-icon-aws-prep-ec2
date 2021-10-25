variable "vpc_id" {
  description = "Custom vpc id - leave blank for deault"
  type        = string
  default     = ""
}

variable "create_sg" {
  type        = bool
  description = "Bool for create security group"
  default     = true
}

variable "public_ports" {
  description = "List of publicly open ports"
  type        = list(number)
  default = [
    22,
    9080,
    8080,
  ]
}

variable "additional_security_group_ids" {
  description = "List of security groups"
  type        = list(string)
  default     = []
}

resource "aws_security_group" "this" {
  count       = var.create_sg && var.create ? 1 : 0
  vpc_id      = var.vpc_id == "" ? null : var.vpc_id
  name        = "${var.name}-sg"
  description = "ICON P-Rep node SG"
  tags        = local.tags
}

resource "aws_security_group_rule" "public_ports" {
  count = var.create_sg && var.create ? length(var.public_ports) : 0

  type              = "ingress"
  security_group_id = join("", aws_security_group.this.*.id)
  protocol          = "tcp"
  from_port         = var.public_ports[count.index]
  to_port           = var.public_ports[count.index]
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prep_egress" {
  count             = var.create_sg && var.create ? 1 : 0
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.this.*.id)
  type              = "egress"
}

output "security_group_id" {
  value = join("", aws_security_group.this.*.id)
}
