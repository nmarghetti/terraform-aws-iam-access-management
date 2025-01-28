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
    groups                        = optional(list(string), [])
  }))
  default = {}
}

variable "iam_existing_users" {
  description = "List of AWS IAM users that exist already and can be referenced."
  type = map(object({
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
    groups       = optional(list(string), [])
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

variable "iam_existing_groups" {
  description = "List of AWS IAM groups that exist already and can be referenced."
  type = map(object({
  }))
  default = {}
}

variable "iam_roles" {
  description = "List of AWS IAM roles to create."
  type = map(object({
    path               = optional(string, "/")
    assume_role_policy = optional(string)
    assume_role_principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
    users        = optional(list(string), [])
    groups       = optional(list(string), [])
  }))
  default = {}
}

variable "aws_ecr_repositories" {
  description = "List of AWS Elastic Container Registry to create."
  type = map(object({
    name                 = optional(string, null)
    image_tag_mutability = optional(string, "MUTABLE")
    force_destroy        = optional(bool, false)
  }))
  default = {}
}
