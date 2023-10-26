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

variable "namespace" {
  type        = string
  default     = "default"
  description = "Namespace where the resource will be deployed. If not specified it will be deployed in 'default' namespace."
}

variable "ssh_keys" {
  type        = string
  description = "List of SSH keys to be added to the authorized keys list."
}
