variable "location" {
  description = "Azure Region"
  type        = string
  default     = "koreacentral"
}

variable "prefix" {
  description = "Resource Prefix"
  type        = string
  default     = "avd-poc"
}

variable "hub_cidr" { default = "10.175.0.0/24" }
variable "spoke_cidr" { default = "10.175.1.0/24" }
variable "vm_admin_username" { default = "pocadmin" }
variable "ssh_public_key" { type = string }
variable "avd_image_id" { type = string }  # Custom Gallery Image
