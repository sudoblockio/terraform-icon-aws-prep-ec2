resource "aws_iam_role" "this" {
  count              = var.create ? 1 : 0
  name               = "${title(var.name)}Role${title(random_pet.this.id)}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_instance_profile" "this" {
  count = var.create ? 1 : 0
  name  = "${title(var.name)}InstanceProfile${title(random_pet.this.id)}"
  role  = join("", aws_iam_role.this.*.name)
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "aws_iam_policy" "eip_attach_policy" {
  count = var.switch_ip_internally && var.create ? 1 : 0

  name   = "${title(var.name)}EIPSwitch${title(random_pet.this.id)}"
  policy = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid":"ReadWrite",
          "Effect":"Allow",
          "Action":["ec2:DescribeAddresses",
                    "ec2:AssociateAddress",
                    "ec2:DisassociateAddress",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DescribeInstances"],
          "Resource":["*"]
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "eip_attach_policy" {
  count      = var.switch_ip_internally && var.create ? 1 : 0
  role       = join("", aws_iam_role.this.*.id)
  policy_arn = aws_iam_policy.eip_attach_policy.*.arn[0]
}
