variable "tags" {
  description = "Tags to be applied to the resource"
  default = {
    Owner = "example@nclouds.com"
  }
  type = map(any)
}