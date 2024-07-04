locals {
  resource_name = var.name_prefix == "" ? var.name : "${var.name_prefix}-${var.name}"
}

resource "kubernetes_config_map" "main" {
  metadata {
    name      = local.resource_name
    namespace = var.namespace
  }

  data = {
    "authorized_keys" = var.ssh_keys
    "motd"            = "Welcome to ${var.motd_name}.\n"
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

        container {
          name  = local.resource_name
          image = "${var.image_repository}:${var.image_tag}"

          env {
            name  = "DOCKER_MODS"
            value = "linuxserver/mods:openssh-server-ssh-tunnel"
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
            name       = "ssh-host-rsa-key"
            mount_path = "/defaults/ssh_host_keys/ssh_host_rsa_key"
            sub_path   = "ssh_host_rsa_key"
          }

          volume_mount {
            name       = "ssh-host-rsa-key-public"
            mount_path = "/defaults/ssh_host_keys/ssh_host_rsa_key_public"
            sub_path   = "ssh_host_rsa_key_public"
          }

          volume_mount {
            name       = "motd"
            mount_path = "/etc/motd"
            sub_path   = "motd"
          }

          liveness_probe {
            tcp_socket {
              port = var.ssh_port
            }

            initial_delay_seconds = 30
          }

          readiness_probe {
            tcp_socket {
              port = var.ssh_port
            }

            initial_delay_seconds = 30
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
  metadata {
    name      = local.resource_name
    namespace = var.namespace

    annotations = var.svc_annotations
  }

  spec {
    selector = {
      app = local.resource_name
    }
    port {
      port        = var.svc_port
      target_port = var.ssh_port
    }

    type = var.svc_type
    load_balancer_class = var.load_balancer_class
  }

  depends_on = [
    kubernetes_deployment.main
  ]
}
