locals {
  resource_name = var.name_prefix == "" ? var.name : "${var.name_prefix}-${var.name}"

  # Default SSH config
  sshd_config = <<-EOT
AllowTcpForwarding yes
AuthorizedKeysFile      .ssh/authorized_keys
ClientAliveCountMax 100
ClientAliveInterval 30
GatewayPorts clientspecified
PasswordAuthentication no
PermitTunnel yes
PidFile /config/sshd.pid
TCPKeepAlive no
X11Forwarding no
HostKey /config/ssh_host_keys/ssh_host_rsa_key
    EOT
}

resource "kubernetes_config_map" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace
  }

  data = {
    "motd"        = "Welcome to ${var.motd_name}"
    "ssh_keys"    = var.ssh_keys
    "sshd_config" = var.sshd_config == "" ? local.sshd_config : var.sshd_config
  }
}
