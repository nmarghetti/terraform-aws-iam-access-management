variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "pgp_key" {
  description = "value of the pgp key to encrypt the secrets"
  type        = string
}

variable "iam_policies" {
  description = "List of AWS IAM policies to create."
  type        = map(any)
  default     = {}
}

variable "iam_users" {
  description = "List of AWS IAM users to create."
  type = map(object({
    create_iam_access_key         = optional(bool, false)
    create_iam_user_login_profile = optional(bool, false)
    password_length               = optional(number, 40)
    password_reset_required       = optional(bool, true)
    force_destroy                 = optional(bool, false)
    policy_arns                   = optional(list(string), [])
    policy_names                  = optional(list(string), [])
  }))
  default = {}
}

variable "iam_existing_users" {
  description = "List of AWS IAM users that exist already and can be referenced."
  type = map(object({
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
  }))
  default = {}
}

variable "aws_secrets" {
  description = "Secret to be stored in AWS Secrets Manager"
  type = map(object({
    region               = string
    robotic_users_reader = list(string)
    users_owner          = list(string)
    secrets              = list(string)
  }))
  default = {}
}

variable "iam_groups" {
  description = "List of AWS IAM groups to create."
  type = map(object({
    path         = optional(string, "/")
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
    users        = optional(list(string), [])
  }))
  default = {}
}

variable "aws_ecr_repositories" {
  description = "List of AWS Elastic Container Registry to create."
  type = map(object({
    image_tag_mutability = optional(string, "MUTABLE")
    force_destroy        = optional(bool, false)
  }))
  default = {}
}

locals {
  groups_policies = merge(
    { for data in flatten([
      for key, group in { for key, group in var.iam_groups : key => {
        pair = [for policy in group.policy_arns : {
          group  = key
          policy = policy
        }]
      } } : group.pair
    ]) : "${data.group} - ${data.policy}" => data },
    { for data in flatten([
      for key, group in { for key, group in var.iam_groups : key => {
        pair = [for policy in group.policy_names : {
          group  = key
          name   = policy
          policy = data.aws_iam_policy.iam_policy[policy].arn
        }]
      } } : group.pair
    ]) : "${data.group} - ${data.name}" => data }
  )
  groups_users = { for data in flatten([
    for key, group in { for key, group in var.iam_groups : key => {
      pair = [for user in group.users : {
        group = key
        user  = user
      }]
    } } : group.pair
    ]) : "${data.group} - ${data.user}" => data
  }
  users_policies = merge(
    { for data in flatten([
      for key, user in { for key, user in var.iam_existing_users : key => {
        pair = [for policy in user.policy_arns : {
          user   = key
          policy = policy
        }]
      } } : user.pair
    ]) : "${data.user} - ${data.policy}" => data },
    { for data in flatten([
      for key, user in { for key, user in var.iam_existing_users : key => {
        pair = [for policy in user.policy_names : {
          user   = key
          name   = policy
          policy = data.aws_iam_policy.iam_policy[policy].arn
        }]
      } } : user.pair
    ]) : "${data.user} - ${data.name}" => data }
  )
}
