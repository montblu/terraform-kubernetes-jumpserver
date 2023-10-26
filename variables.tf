variable "name" {
  type        = string
  default     = "jumpserver"
  description = "Name of the resource. Defaults to 'jumpserver'"
}

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Prefix of the resource. If not specified it won't add a prefix."
}
