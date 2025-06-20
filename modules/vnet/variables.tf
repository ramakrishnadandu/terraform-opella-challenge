variable "vnet_name" {}
variable "location" {}
variable "address_space" { type = list(string) }
variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
}
variable "resource_group_name" {}
variable "tags" { type = map(string) }


