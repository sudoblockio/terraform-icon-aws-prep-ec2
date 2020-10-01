variable "create" {
  description = "Boolean to create resources or not"
  type        = bool
  default     = true
}

//variable "minimum_specs" {
//  description = "Boolean to use minimum specs"
//  type        = bool
//  default     = false
//}


########
# Label
########
variable "name" {
  description = "The name for the label"
  type        = string
  default     = "prep"
}

variable "tags" {
  description = "Map of tags"
  type        = map(string)
  default     = {}
}

variable "network_name" {
  description = "The network name, ie kusama / mainnet"
  type        = string
}

######
# Data
######
variable "public_ip" {
  description = "The public IP of the elastic ip to attach to active instance"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The id of the subnet"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "Custom vpc id - leave blank for deault"
  type        = string
  default     = ""
}

variable "create_sg" {
  type        = bool
  description = "Bool for create security group"
  default     = false
}

variable "public_ports" {
  description = "List of publicly open ports"
  type        = list(number)
  default = [
    22,
    7100,
    9000,
    9100,
    9113,
    9115,
    8080,
  ]
}

variable "private_ports" {
  description = "List of publicly open ports"
  type        = list(number)
  default = [
    9100,
    9113,
    9115,
    8080,
  ]
}

variable "private_port_cidrs" {
  description = "List of CIDR blocks for private ports"
  type        = list(string)
  default     = ["172.31.0.0/16"]
}

variable "additional_security_group_ids" {
  description = "List of security groups"
  type        = list(string)
  default     = []
}

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
  default     = 8
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

variable "logs_bucket_enable" {
  description = "Create bucket to put logs"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "Name of bucket for logs - blank for logs-<account-id>"
  type        = string
  default     = ""
}

#########
# Ansible
#########
variable "ansible_hardening" {
  description = "Run hardening roles"
  type        = bool
  default     = false
}

variable "playbook_vars" {
  description = "Additional playbook vars"
  type        = map(string)
  default     = {}
}

variable "keystore_path" {
  description = "The path to the keystore"
  type        = string
  default     = ""
}

variable "keystore_password" {
  description = "The password to the keystore"
  type        = string
  default     = ""
}

variable "operator_keystore_password" {
  description = "the path to your keystore"
  type        = string
  default     = ""
}

variable "operator_keystore_path" {
  description = "The keystore password"
  type        = string
  default     = ""
}

//variable "main_ip" {
//  description = "The main IP that was registered"
//  type = string
//}

variable "associate_eip" {
  description = "Boolean to determine if you should associate the ip when the instance has been configured"
  type        = bool
  default     = true
}

//variable "private_key_path" {
//  description = "Path to the private ssh key"
//  type        = string
//  default     = ""
//}
//
//variable "playbook_file_path" {
//  description = "The path to the playbook"
//  type        = string
//  default     = ""
//}
//
//variable "user" {
//  description = "The user for configuring node with ansible"
//  type        = string
//  default     = "ubuntu"
//}



