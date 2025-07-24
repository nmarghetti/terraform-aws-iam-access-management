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

output "debug_iam_inputs" {
  value = {
    input_users_name    = local.input_users_name
    input_groups_name   = local.input_groups_name
    input_policies_name = local.input_policies_name
    groups_name         = local.groups_name
    users_name          = local.users_name
    groups_users        = local.groups_users
    policies_name       = local.policies_name
    groups_policies     = local.groups_policies
    users_policies      = local.users_policies
    roles_policies      = local.roles_policies
    policies_undefined  = local.policies_undefined
    groups_undefined    = local.groups_undefined
    users_undefined     = local.users_undefined
  }
}
