#####
# EBS
#####
variable "create_ebs_volume" {
  type    = bool
  default = false
}

//variable "ebs_volume_id" {
//  type        = string
//  default     = ""
//  description = "The volume id of the ebs volume to mount"
//}
//
//variable "ebs_volume_size" {
//  description = "The size of volume - leave as zero or empty for no volume"
//  type        = number
//  default     = 0
//}
//
//variable "ebs_volume_type" {
//  description = "Type of EBS - https://aws.amazon.com/ebs/volume-types/"
//  type        = string
//  default     = "gp2"
//}

//variable "ebs_volome_iops" {
//  description = ""
//  type        = string
//  default     = null
//}

variable "volume_path" {
  description = "The path of the EBS volume"
  type        = string
  default     = "/dev/xvdf"
}



//resource "aws_ebs_volume" "this" {
//  count = ! local.instance_store_enabled && var.create && var.ebs_volume_size > 0 ? 1 : 0
//
//  availability_zone = join("", aws_instance.this.*.availability_zone)
//
//  size = var.ebs_volume_size
//  type = var.ebs_volume_type
//  iops = var.ebs_volome_iops
//
//  tags = local.tags
//}
//
//resource "aws_volume_attachment" "this" {
//  count = ! local.instance_store_enabled && var.create && var.ebs_volume_size > 0 ? 1 : 0
//
//  device_name  = var.volume_path
//  volume_id    = aws_ebs_volume.this.*.id[0]
//  instance_id  = join("", aws_instance.this.*.id)
//  force_detach = true
//}

//resource "aws_iam_policy" "ebs_mount_policy" {
//  count  = ! local.instance_store_enabled && var.create && var.ebs_volume_size > 0 ? 1 : 0
//  name   = "${title(var.name)}EbsMountPolicy${title(random_pet.this.id)}"
//  policy = <<-EOT
//{
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//            "Sid": "EbsVolumeAttach",
//            "Effect": "Allow",
//            "Action": [
//                "ec2:AttachVolume"
//            ],
//            "Resource": "[${aws_ebs_volume.this.*.arn[0]},${aws_instance.this.*.arn[0]}]"
//        },
//        {
//            "Sid": "EbsVolumeDescribe",
//            "Effect": "Allow",
//            "Action": [
//                "ec2:DescribeVolumeStatus",
//                "ec2:DescribeVolumes",
//                "ec2:DescribeVolumeAttribute",
//                "ec2:DescribeInstances"
//            ],
//            "Resource": "*"
//        }
//    ]
//}
//EOT
//}

//resource "aws_iam_role_policy_attachment" "ebs_mount_policy" {
//  count      = ! local.instance_store_enabled && var.create && var.ebs_volume_size > 0 ? 1 : 0
//  role       = join("", aws_iam_role.this.*.id)
//  policy_arn = aws_iam_policy.ebs_mount_policy.*.arn[0]
//}

//resource "aws_iam_policy" "s3_put_logs_policy" {
//  count = var.logs_bucket_enable && var.create ? 1 : 0
//
//  name   = "${title(var.name)}S3PutLogsPolicy${title(random_pet.this.id)}"
//  policy = <<-EOT
//{
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//          "Sid":"ReadWrite",
//          "Effect":"Allow",
//          "Action":["s3:GetObject", "s3:PutObject"],
//          "Resource":["arn:aws:s3:::${aws_s3_bucket.logs.*.bucket[0]}/*"]
//        }
//    ]
//}
//EOT
//}
//
//resource "aws_iam_role_policy_attachment" "s3_put_logs_policy" {
//  count      = var.ebs_volume_size > 0 && var.create ? 1 : 0
//  role       = join("", aws_iam_role.this.*.id)
//  policy_arn = aws_iam_policy.eip_attach_policy.*.arn[0]
//}