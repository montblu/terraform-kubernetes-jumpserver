variable "motd_name" {
  type        = string
  default     = "jumpserver"
  description = "Name of the place where the user joined. Defaults to 'jumpserver', so it shows: 'Welcome to jumpserver'"
}

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

variable "sshd_config" {
  type        = string
  default     = ""
  description = "Configuration file for SSH. If not defined it will use the default."
}


variable "ssh_host_rsa_key" {
  type        = string
  default     = ""
  description = "Private key used by the OpenSSH server. If not defined it will generated automatically, but won't be saved."
}

variable "ssh_host_rsa_key_public" {
  type        = string
  default     = ""
  description = "Public key used by the OpenSSH server. If not defined it will generated automatically, but won't be saved."
}

variable "image_repository" {
  type        = string
  default     = "linuxserver/openssh-server"
  description = "Repository of the image used to deploy the jumpserver."
}

variable "image_tag" {
  type        = string
  default     = "9.3_p2-r0-ls133"
  description = "Tag of the image used to deploy the jumpserver."
}

variable "svc_annotations" {
  type        = map(any)
  default     = {}
  description = "Map of annotations for the service."
}

variable "svc_type" {
  type        = string
  default     = "LoadBalancer"
  description = "Type of LoadBalancer."
}
