variable "location" {
  type    = string
  default = "eastus"
}
variable "alias" {
  description = "Alias for all resources created"
  type        = string
  default     = "dev"
}

variable "ssh-source-address" {
  type    = string
  default = "*"
}

variable "rdp" {
  type    = string
  default = "*"
}

variable "resource_group_name" {
  description = "Name of the resource group to be imported."
  type        = string
  default     = "eliteInfra"
}
variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = ["public-sb", "subnet2", "subnet3"]
}
variable "vnet_name" {
  description = "Name of the vnet to create"
  type        = string
  default     = "elitedevvnet"
}