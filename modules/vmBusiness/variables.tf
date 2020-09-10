variable "vm_name" {
  type        = list(string)
  default     = [ "vmBusiness1", "vmBusiness2"]
}
variable "nic_name" {
  type        = list(string)
  default     = [ "businessNic1", "businessNic2"]
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

