locals {
  resource_name = var.name_prefix == "" ? var.name : "${var.name_prefix}-${var.name}"
  port_name     = substr("${var.name}-port", 0, 14) # must be no more than 15 characters
}

resource "kubernetes_config_map" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace
  }

  data = {
    "authorized_keys"           = var.ssh_keys
    "motd"                      = "Welcome to ${var.motd_name}.\n"
    "delete-generated-ssh-keys" = <<EOT
#!/bin/bash
echo "**** remove not needed ecdsa and ed25519 keys ****"
rm /config/ssh_host_keys/ssh_host_ecdsa*
rm /config/ssh_host_keys/ssh_host_ed25519*
EOT
    "mac_algorithms.conf"       = <<EOT
MACs umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512
EOT
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
    labels = {
      app = local.resource_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        type = "jumpserver"
      }
    }

    template {
      metadata {
        labels = {
          app  = local.resource_name
          type = "jumpserver"
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
          name = "authorized-keys"

          config_map {
            name = local.resource_name

            items {
              key  = "authorized_keys"
              path = "authorized_keys"
            }
          }
        }

        volume {
          name = "delete-generated-ssh-keys"

          config_map {
            name = local.resource_name

            items {
              key  = "delete-generated-ssh-keys"
              path = "delete-generated-ssh-keys"
            }
          }
        }

        volume {
          name = "ssh-host-rsa-key"

          secret {
            secret_name = local.resource_name

            items {
              key  = "ssh_host_rsa_key"
              path = "ssh_host_rsa_key"
            }
          }
        }

        volume {
          name = "ssh-host-rsa-key-public"

          secret {
            secret_name = local.resource_name

            items {
              key  = "ssh_host_rsa_key_public"
              path = "ssh_host_rsa_key_public"
            }
          }
        }

        volume {
          name = "mac-algorithms-conf"

          config_map {
            name = local.resource_name

            items {
              key  = "mac_algorithms.conf"
              path = "mac_algorithms.conf"
            }
          }
        }

        container {
          name  = local.resource_name
          image = "${var.image_repository}:${var.image_tag}"

          port {
            name           = local.port_name
            container_port = 2222
          }

          env {
            # Ref: https://github.com/linuxserver/docker-mods/tree/openssh-server-ssh-tunnel
            name  = "DOCKER_MODS"
            value = "linuxserver/mods:openssh-server-ssh-tunnel${var.ssh_log_to_stdout ? "|linuxserver/mods:universal-stdout-logs" : ""}"
          }

          dynamic "env" {
            for_each = var.ssh_log_to_stdout ? ["dummy"] : []
            content {
              name  = "LOGS_TO_STDOUT"
              value = "/config/logs/openssh/current" # OpenSSH logs
            }
          }

          env {
            name  = "PUBLIC_KEY_FILE"
            value = "/defaults/authorized_keys"
          }

          env {
            name  = "SHELL_NOLOGIN"
            value = var.shell_no_login
          }

          env {
            name  = "USER_NAME"
            value = var.ssh_user
          }

          volume_mount {
            name       = "authorized-keys"
            mount_path = "/defaults/authorized_keys"
            sub_path   = "authorized_keys"
          }

          volume_mount {
            name       = "delete-generated-ssh-keys"
            mount_path = "/custom-cont-init.d/delete-generated-ssh-keys"
            sub_path   = "delete-generated-ssh-keys"
            read_only  = true
          }

          volume_mount {
            name       = "ssh-host-rsa-key"
            mount_path = "/config/ssh_host_keys/ssh_host_rsa_key"
            sub_path   = "ssh_host_rsa_key"
          }

          volume_mount {
            name       = "ssh-host-rsa-key-public"
            mount_path = "/config/ssh_host_keys/ssh_host_rsa_key_public"
            sub_path   = "ssh_host_rsa_key_public"
          }

          volume_mount {
            name       = "motd"
            mount_path = "/etc/motd"
            sub_path   = "motd"
          }

          volume_mount {
            name       = "mac-algorithms-conf"
            mount_path = "/config/sshd/sshd_config.d/mac_algorithms.conf"
            sub_path   = "mac_algorithms.conf"
          }

          liveness_probe {
            tcp_socket {
              port = var.ssh_port
            }
          }

          readiness_probe {
            tcp_socket {
              port = var.ssh_port
            }
          }
        }
        dynamic "host_aliases" {
          for_each = var.host_aliases

          content {
            ip        = host_aliases.value.ip
            hostnames = host_aliases.value.hostnames
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

resource "kubernetes_service" "main" {
  count = var.svc_create ? 1 : 0

  metadata {
    name      = local.resource_name
    namespace = var.namespace

    annotations = var.svc_annotations
  }

  spec {
    selector = {
      type = "jumpserver"
    }

    port {
      name        = "${local.resource_name}-port"
      port        = var.svc_port
      target_port = "2222"
    }

    type                = var.svc_type
    load_balancer_class = var.load_balancer_class
  }

  depends_on = [
    kubernetes_deployment.main
  ]
}
