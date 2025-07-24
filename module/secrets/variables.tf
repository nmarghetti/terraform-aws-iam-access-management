variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS Secret Manager region"
  type        = string
}

variable "robotic_users_reader" {
  description = "Robotic IAM user that can read secrets from AWS Secrets Manager"
  type        = list(string)
  default     = []
}

variable "users_owner" {
  description = "IAM user that can manage secrets from AWS Secrets Manager"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.users_owner) > 0
    error_message = "You need to add at least one owner for the secret, otherwise no one would be able to modify its resource policy."
  }
}

variable "secret_project_name" {
  description = "Prefix for the secret name"
  type        = string
}

variable "secrets" {
  description = "Secrets to be stored in AWS Secrets Manager"
  type        = list(string)
  default     = []
}

variable "prefix" {
  description = "Prefix for the roles/permissions related to the secrets"
  type        = string
  default     = "aws_secret_"
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}
