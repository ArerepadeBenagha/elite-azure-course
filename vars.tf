variable "location" {
  type    = string
  default = "EAST US"
}
variable "alias" {
  type    = string
  default = "dev"
}

variable "ssh-source-address" {
  type    = string
  default = "*"
}

variable "rdp" {
  type    = string
  default = "*"
}