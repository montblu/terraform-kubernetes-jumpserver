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
  description = "List of SSH keys to be added to the authorized keys list. Should be in the same format as the 'authorized_keys' file, represented in Heredoc style as a multi-line string value."
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

variable "ssh_user" {
  type        = string
  default     = "user"
  description = "Specify a username to connect to. If not defined it will use 'user' as default."
}

variable "ssh_port" {
  type        = number
  default     = 2222
  description = "Specify the port that OpenSSH server will bind to. The port value can't be below 1024. If not defined it will use '2222' as default."
}

variable "image_repository" {
  type        = string
  default     = "linuxserver/openssh-server"
  description = "Repository of the image used to deploy the jumpserver."
}

variable "image_tag" {
  type        = string
  default     = "9.7_p1-r4-ls163"
  description = "Tag of the image used to deploy the jumpserver."
}

variable "svc_create" {
  type        = bool
  default     = true
  description = "If set to true it will create the service."
}

variable "svc_annotations" {
  type        = map(any)
  default     = {}
  description = "Map of annotations for the service."
}

variable "svc_type" {
  type        = string
  default     = "LoadBalancer"
  description = "Type of the Service"
}

variable "svc_port" {
  type        = number
  default     = 22
  description = "Port where the OpenSSH will be exposed. If not defined it will use '22' as default"
}

variable "load_balancer_class" {
  type        = string
  default     = null
  description = "The class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix. This field can only be set when the svc_type is LoadBalancer"
}

variable "shell_no_login" {
  type        = bool
  default     = true
  description = "Determines whether it is possible to login into shell when connecting via SSH with the created user. By default the user is not allowed to shell via SSH, to change this behaviour please set this variable to 'false'"
}

