output "aws_iam_users" {
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

output "aws_iam_users_credentials" {
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

output "aws_iam_groups" {
  description = "AWS IAM groups"
  value       = resource.aws_iam_group.iam_groups
}

output "aws_iam_roles" {
  description = "AWS IAM roles"
  value       = resource.aws_iam_role.iam_roles
}

output "aws_iam_policies" {
  description = "AWS IAM policies"
  value       = resource.aws_iam_policy.iam_policies
}

output "aws_iam_users_by_groups" {
  description = "List of IAM users by groups"
  value       = local.groups_users
}
