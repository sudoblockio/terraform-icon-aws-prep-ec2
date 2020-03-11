resource "random_pet" "this" {}

module "label" {
  source = "github.com/robc-io/terraform-null-label.git?ref=0.16.1"

  name = var.name

  tags = {
    NetworkName = var.network_name
    Owner       = var.owner
    Terraform   = true
    VpcType     = "main"
  }

  environment = var.environment
  namespace   = var.namespace
  stage       = var.stage
}

module "ami" {
  source = "github.com/insight-infrastructure/terraform-aws-ami.git?ref=master"
}

resource "aws_eip" "this" {
  tags = merge({
    Name = "prep"
  }, module.label.tags)
  depends_on = [
  aws_instance.this]
}

resource "aws_eip_association" "this" {
  instance_id = aws_instance.this.id
  public_ip   = aws_eip.this.public_ip
}

resource "aws_key_pair" "this" {
  count      = var.public_key_path == "" ? 0 : 1
  public_key = file(var.public_key_path)
}

resource "aws_ebs_volume" "this" {
  count = var.ebs_volume_size > 0 ? 1 : 0

  availability_zone = aws_instance.this.availability_zone

  size = var.ebs_volume_size
  type = "gp2"

  tags = merge({ Mount : "data" }, module.label.tags)
}

resource "aws_volume_attachment" "this" {
  count = var.ebs_volume_size > 0 ? 1 : 0

  device_name = var.volume_path

  volume_id = aws_ebs_volume.this.*.id[0]

  instance_id  = aws_instance.this.id
  force_detach = true
}

data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "logs" {
  count  = var.logs_bucket_enable ? 1 : 0
  bucket = "logs-${data.aws_caller_identity.this.account_id}"
  acl    = "private"
  tags   = module.label.tags
}



resource "aws_instance" "this" {
  ami           = module.ami.ubuntu_1804_ami_id
  instance_type = var.instance_type

  root_block_device {
    volume_size = var.root_volume_size
  }

  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile = aws_iam_instance_profile.this.id
  key_name             = var.public_key_path == "" ? var.key_name : aws_key_pair.this.*.key_name[0]

  tags = module.label.tags
}

module "ansible" {
  source           = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=master"
  ip               = aws_eip_association.this.public_ip
  user             = "ubuntu"
  private_key_path = var.private_key_path

  playbook_file_path = "${path.module}/ansible/main.yml"
  playbook_vars = merge({
    keystore_path     = var.keystore_path,
    keystore_password = var.keystore_password,
    network_name      = var.network_name
  }, var.playbook_vars)

  requirements_file_path = "${path.module}/ansible/requirements.yml"
}
