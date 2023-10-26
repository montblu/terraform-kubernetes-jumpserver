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
    "authorized_keys" = var.ssh_keys
    "motd"            = "Welcome to ${var.motd_name}"
    "sshd_config"     = var.sshd_config == "" ? local.sshd_config : var.sshd_config
  }
}

resource "kubernetes_secret" "main" {
  count = (var.ssh_host_rsa_key != "") && (var.ssh_host_rsa_key_public != "") ? 1 : 0

  metadata {
    name      = local.resource_name
    namespace = var.namespace
  }

  data = {
    "ssh_host_rsa_key"        = var.ssh_host_rsa_key
    "ssh_host_rsa_key_public" = var.ssh_host_rsa_key_public
  }
}

resource "kubernetes_deployment" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.resource_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.resource_name
        }
      }

      spec {
        volume {
          name = "motd"

          config_map {
            name = local.resource_name

            items {
              key  = "motd"
              path = "motd"
            }
          }
        }

        volume {
          name = "authorized_keys"

          config_map {
            name = local.resource_name

            items {
              key  = "authorized_keys"
              path = "authorized_keys"
            }
          }
        }

        volume {
          name = "sshd_config"

          config_map {
            name = local.resource_name

            items {
              key  = "sshd_config"
              path = "sshd_config"
            }
          }
        }

        volume {
          name = "ssh_host_rsa_key"

          secret {
            secret_name = local.resource_name

            items {
              key  = "ssh_host_rsa_key"
              path = "ssh_host_rsa_key"
            }
          }
        }

        volume {
          name = "ssh_host_rsa_key_public"

          secret {
            secret_name = local.resource_name

            items {
              key  = "ssh_host_rsa_key_public"
              path = "ssh_host_rsa_key_public"
            }
          }
        }

        container {
          name  = local.resource_name
          image = "${var.image_repository}:${var.image_tag}"

          env {
            name  = "USER_NAME"
            value = "user"
          }

          volume_mount {
            name       = "motd"
            mount_path = "/etc/motd"
            sub_path   = "motd"
          }

          volume_mount {
            name       = "authorized_keys"
            mount_path = "/config/.ssh/authorized_keys"
            sub_path   = "authorized_keys"
          }

          volume_mount {
            name       = "sshd_config"
            mount_path = "/config/ssh_host_keys/sshd_config"
            sub_path   = "sshd_config"
          }

          volume_mount {
            name       = "ssh_host_rsa_key"
            mount_path = "/config/ssh_host_keys/ssh_host_rsa_key"
            sub_path   = "ssh_host_rsa_key"
          }

          volume_mount {
            name       = "ssh_host_rsa_key_public"
            mount_path = "/config/ssh_host_keys/ssh_host_rsa_key_public"
            sub_path   = "ssh_host_rsa_key_public"
          }
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = 0
        max_unavailable = 1
      }
    }
  }

  depends_on = [
    kubernetes_config_map.main,
    kubernetes_secret.main
  ]
}
