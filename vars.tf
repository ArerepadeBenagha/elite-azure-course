variable "ssh-source-address" {
  type    = string
  default = "*"
}
variable "rdp" {
  type    = string
  default = "*"
}
variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = ["public-sb", "subnet2", "subnet3"]
}
variable "path_to_public_key" {
  description = "Name of the public ssh key to connect to vm"
  type        = string
  default     = "id_rsa.pub"
}