# terraform-aws-iam-access-management

## Terraform

Published to Terraform registry following <https://developer.hashicorp.com/terraform/registry/modules/publish>.

Available at [iam-access-management](https://registry.terraform.io/modules/nmarghetti/iam-access-management/aws/latest).

Here is an example of use: [terraform-aws-iam-access-management-example](https://github.com/nmarghetti/terraform-aws-iam-access-management-example)

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_null"></a> [null](#requirement_null)                | >= 5.0   |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 3.0   |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 5.0  |

## Modules

| Name                                                                                                 | Source                                         | Version |
| ---------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ------- |
| <a name="module_this"></a> [this](#module_this)                                                      | nmarghetti/terraform-aws-iam-access-management | 1.1.6   |
| [iam-user](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v5.48.0/modules/iam-user) | terraform-aws-modules/terraform-aws-iam        | 5.48.0  |
