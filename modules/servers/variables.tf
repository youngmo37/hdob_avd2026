variable "prefix"    { type = string }
variable "location"  { type = string }
variable "rg_name"   { type = string }
variable "subnet_id" { type = string }

variable "vm_size"      { type = string }
variable "admin_user"   { type = string }
variable "admin_pass"   { type = string }  # Windows용 추가
variable "ssh_key"      { type = string }
variable "os_disk_size" { type = number }
