variable "vm_name" {
  type        = list(string)
  default     = [ "vmWeb1", "vmWeb2"]
}
variable "nic_name" {
  type        = list(string)
  default     = [ "webNic1", "webNic2"]
}
variable "location" {
  type    = string
  default = "East US"
}
variable "resource_group_name" {
  type    = string
}
variable "subnet_id" {
  type    = string
}

