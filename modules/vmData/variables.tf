variable "vm_name" {
  type        = list(string)
  default     = [ "vmData1", "vmData2"]
}
variable "nic_name" {
  type        = list(string)
  default     = [ "dataNic1", "dataNic2"]
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
