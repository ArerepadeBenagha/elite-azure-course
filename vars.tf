variable "location" {
  type    = string
  default = "West US 2"
}
variable "alias" {
  type    = string
  default = "dev"
}

variable "ssh-source-address" {
  type    = string
  default = "*"
}
