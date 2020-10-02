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


