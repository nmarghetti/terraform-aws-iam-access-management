variable "aws_iam_policies" {
  description = "List of AWS IAM policies to create."
  type        = map(string)
  default     = {}
}

variable "aws_iam_policy_documents" {
  description = "List of AWS IAM policy documents to create."
  type = map(object({
    json    = string
    version = string
    statement = list(object({
      sid       = optional(string)
      effect    = string
      actions   = list(string)
      resources = list(string)
    }))
  }))
  default = {}
}

variable "aws_iam_existing_policies" {
  description = "List of AWS IAM policies that exist already and can be referenced."
  type        = map(object({}))
  default     = {}
}

variable "aws_iam_users" {
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

variable "aws_iam_existing_users" {
  description = "List of AWS IAM users that exist already and can be referenced."
  type = map(object({
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
    groups       = optional(list(string), [])
  }))
  default = {}
}

variable "aws_iam_groups" {
  description = "List of AWS IAM groups to create."
  type = map(object({
    path         = optional(string, "/")
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
    users        = optional(list(string), [])
  }))
  default = {}
}

variable "aws_iam_existing_groups" {
  description = "List of AWS IAM groups that exist already and can be referenced."
  type = map(object({
    policy_arns  = optional(list(string), [])
    policy_names = optional(list(string), [])
  }))
  default = {}
}

variable "aws_iam_roles" {
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
