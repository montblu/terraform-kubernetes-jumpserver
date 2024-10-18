# terraform-kubernetes-jumpserver

## How to generate ssh keys

We need to generate a ssh key pair for the jumpserver to use. You can do this by running the following command:

```bash
ssh-keygen -t ed25519 -C "<name-of-the-jumpserver>" -f <name-of-the-jumpserver>
```

After that you will have a `<name-of-the-jumpserver>` file with the private key and a `<name-of-the-jumpserver>.pub` file with the public key.

```hcl
ssh_host_rsa_key        = <content-of-the-jumpserver-file>
ssh_host_rsa_key_public = <content-of-the-jumpserver-file.pub>
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_secret.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_repository"></a> [image\_repository](#input\_image\_repository) | Repository of the image used to deploy the jumpserver. | `string` | `"linuxserver/openssh-server"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag of the image used to deploy the jumpserver. | `string` | `"9.7_p1-r4-ls163"` | no |
| <a name="input_load_balancer_class"></a> [load\_balancer\_class](#input\_load\_balancer\_class) | The class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix. This field can only be set when the svc\_type is LoadBalancer | `string` | `"service.k8s.aws/nlb"` | no |
| <a name="input_motd_name"></a> [motd\_name](#input\_motd\_name) | Name of the place where the user joined. Defaults to 'jumpserver', so it shows: 'Welcome to jumpserver' | `string` | `"jumpserver"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource. Defaults to 'jumpserver' | `string` | `"jumpserver"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix of the resource. If not specified it won't add a prefix. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the resource will be deployed. If not specified it will be deployed in 'default' namespace. | `string` | `"default"` | no |
| <a name="input_shell_no_login"></a> [shell\_no\_login](#input\_shell\_no\_login) | Determines whether it is possible to login into shell when connecting via SSH with the created user. By default the user is not allowed to shell via SSH, to change this behaviour please set this variable to 'false' | `bool` | `true` | no |
| <a name="input_ssh_host_rsa_key"></a> [ssh\_host\_rsa\_key](#input\_ssh\_host\_rsa\_key) | Private key used by the OpenSSH server. If not defined it will generated automatically, but won't be saved. | `string` | `""` | no |
| <a name="input_ssh_host_rsa_key_public"></a> [ssh\_host\_rsa\_key\_public](#input\_ssh\_host\_rsa\_key\_public) | Public key used by the OpenSSH server. If not defined it will generated automatically, but won't be saved. | `string` | `""` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | List of SSH keys to be added to the authorized keys list. Should be in the same format as the 'authorized\_keys' file, represented in Heredoc style as a multi-line string value. | `string` | n/a | yes |
| <a name="input_ssh_log_to_stdout"></a> [ssh\_log\_to\_stdout](#input\_ssh\_log\_to\_stdout) | If set to true it will log the SSH connection to stdout. | `bool` | `true` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | Specify the port that OpenSSH server will bind to. The port value can't be below 1024. If not defined it will use '2222' as default. | `number` | `2222` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Specify a username to connect to. If not defined it will use 'user' as default. | `string` | `"user"` | no |
| <a name="input_svc_annotations"></a> [svc\_annotations](#input\_svc\_annotations) | Map of annotations for the service. | `map(any)` | `{}` | no |
| <a name="input_svc_create"></a> [svc\_create](#input\_svc\_create) | If set to true it will create the service. | `bool` | `true` | no |
| <a name="input_svc_port"></a> [svc\_port](#input\_svc\_port) | Port where the OpenSSH will be exposed. If not defined it will use '22' as default | `number` | `22` | no |
| <a name="input_svc_type"></a> [svc\_type](#input\_svc\_type) | Type of the Service | `string` | `"LoadBalancer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_port_name"></a> [port\_name](#output\_port\_name) | Name of the port of the container |
<!-- END_TF_DOCS -->
