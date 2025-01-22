output "iam_users" {
  description = "IAM users"
  value = merge(
    { for user in data.aws_iam_user.iam_existing_user : user.user_name =>
      merge(user, {
        existing = true
      })
    },
    { for user in data.aws_iam_user.iam_user : user.user_name =>
      merge(user, {
        existing = false
      })
    }
  )
}

output "iam_users_credentials" {
  description = "IAM users credentials"
  sensitive   = true
  value = {
    for user in module.iam_users : user.iam_user_name => {
      iam_access_key_id = user.iam_access_key_id
      secret_access_key = user.keybase_secret_key_pgp_message
      password          = user.keybase_password_pgp_message
    }
  }
}

output "aws_secrets" {
  description = "AWS secrets"
  value = {
    for key, secret in module.secrets : key => {
      secrets = secret.secrets
      role    = secret.role
    }
  }
}

output "iam_groups" {
  description = "AWS IAM groups"
  value       = resource.aws_iam_group.iam_groups
}

output "iam_policies" {
  description = "AWS IAM policies"
  value       = resource.aws_iam_policy.iam_policies
}
