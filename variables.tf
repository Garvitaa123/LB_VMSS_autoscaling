variable "subscription_id" {
  description = "Azure subscription ID (required by azurerm 4.x)"
  type        = string
}

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "demo"
}

variable "location" {
  type    = string
  default = "South India"
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "vm_size" {
  type    = string
  default = "Standard_B2as_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to OpenSSH-format public key (for PuTTY, export from PuTTYgen -> 'Public key for pasting into OpenSSH')"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  description = "Source IP/CIDR allowed to SSH to the bastion. Change from * to your public IP, e.g. 203.0.113.5/32"
  type        = string
  default     = "*"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "web_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "db_subnet_cidr" {
  type    = string
  default = "10.0.4.0/24"
}
