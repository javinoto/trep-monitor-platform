variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "trepmon"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "storage_sku" {
  description = "SKU for the Storage Account"
  type        = string
  default     = "Standard_LRS"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    project     = "trep-monitor-platform"
  }
}
