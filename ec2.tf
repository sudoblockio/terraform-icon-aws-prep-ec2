
#####
# ec2
#####
variable "key_name" {
  description = "The key pair to import - leave blank to generate new keypair from pub/priv ssh key path"
  type        = string
  default     = ""
}

variable "monitoring" {
  description = "Boolean for cloudwatch"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root volume size"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = ""
  type        = string
  default     = "gp2"
}

variable "root_iops" {
  description = ""
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.small"
}

variable "public_key_path" {
  description = "The path to the public ssh key"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private ssh key"
  type        = string
}


variable "subnet_id" {
  description = "The id of the subnet"
  type        = string
  default     = ""
}

variable "iam_instance_profile_id" {
  description = "Instance profile ID"
  type        = string
  default     = null
}

variable "minimum_volume_size_map" {
  description = "Map for networks with min volume size "
  type        = map(string)
  default = {
    mainnet = 500,
    testnet = 70
    zicon   = 70
    bicon   = 70
  }
}

module "ami" {
  source = "github.com/insight-infrastructure/terraform-aws-ami.git?ref=v0.1.0"
}

resource "aws_key_pair" "this" {
  count      = var.public_key_path != "" && var.create ? 1 : 0
  public_key = file(pathexpand(var.public_key_path))
  tags       = local.tags
}

locals {
  tags = merge(var.tags, { Name = var.name })
}

locals {
  instance_family        = split(".", var.instance_type)[0]
  instance_size          = split(".", var.instance_type)[1]
  instance_store_enabled = contains(["m5d", "m5ad", "m5dn", "r5dn", "r5d", "z1d", "c5d", "c5ad", "c3", "i3", "i3en"], local.instance_family)

  root_volume_size = local.instance_store_enabled ? var.root_volume_size : var.root_volume_size == 20 ? lookup(var.minimum_volume_size_map, var.network_name) : var.root_volume_size
  volume_path      = "/dev/xvdf"
}

resource "aws_instance" "this" {
  count         = var.create ? 1 : 0
  ami           = module.ami.ubuntu_1804_ami_id
  instance_type = var.instance_type

  root_block_device {
    volume_size = local.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_iops
  }

  subnet_id              = var.subnet_id
  vpc_security_group_ids = compact(concat(aws_security_group.this.*.id, var.additional_security_group_ids))

  iam_instance_profile = var.iam_instance_profile_id
  key_name             = var.public_key_path == "" ? var.key_name : aws_key_pair.this.*.key_name[0]

  tags = local.tags
}

