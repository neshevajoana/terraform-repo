variable "name" {
  type    = string
  default = "dmzVnet"
}
variable "address_space" {
  type = list(string)
}
variable "location" {
  type    = string
  default = "East US"
}
variable "resource_group_name" {
  type    = string
}


