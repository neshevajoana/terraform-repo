variable "name" {
  type    = string
  default = "virtual_network_dmz"
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


