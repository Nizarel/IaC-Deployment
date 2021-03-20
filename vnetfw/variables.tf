variable "fw-rg-name" {
  type    = string
  default = "fw-rg"
}
variable "location-name" {
  type    = string
  default = "eastus"
}
variable "fw-vnet-name" {
  type    = string
  default = "fw-vnet"
}
variable "jb-sub-name" {
  type    = string
  default = "jbox-subnet"
}
variable "pip-name" {
  type    = string
  default = "pub-ip01"
}
variable "fw-name" {
  type    = string
  default = "fw-01"
}
variable "be-rg-name" {
  type    = string
  default = "be-rg"
}
variable "web-vnet-name" {
  type    = string
  default = "web-vnet"
}
variable "web-sub-name" {
  type    = string
  default = "web-subnet"
}
variable "web-vm-name" {
  type    = string
  default = "Web"
}
variable "jb-rg-name" {
  type    = string
  default = "jbox-rg"
}
variable "jb-vm-name" {
  type    = string
  default = "jbox"
}
variable "admin_username" {
  type    = string
  default = "adminuser"
}
variable "admin_password" {
  type    = string
  default = "P@$$w0rd1234!"
}