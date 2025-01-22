# https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v5.48.0/modules/iam-user
# https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v5.48.0/examples/iam-user
module "iam_users" {
  depends_on = [resource.aws_iam_policy.iam_policies]

  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.48.0"

  for_each                      = { for key, user in var.iam_users : key => user }
  pgp_key                       = var.pgp_key
  tags                          = var.tags
  create_user                   = true
  name                          = each.key
  create_iam_access_key         = each.value.create_iam_access_key
  create_iam_user_login_profile = each.value.create_iam_user_login_profile
  password_length               = each.value.password_length
  password_reset_required       = each.value.password_reset_required
  force_destroy                 = each.value.force_destroy
  policy_arns                   = concat(each.value.policy_arns, [for policy in each.value.policy_names : resource.aws_iam_policy.iam_policies[policy].arn])
}

module "secrets" {
  depends_on = [module.iam_users]
  source     = "./module/secrets"

  for_each             = { for key, secret in var.aws_secrets : key => secret }
  tags                 = var.tags
  secret_project_name  = each.key
  region               = each.value.region
  secrets              = each.value.secrets
  robotic_users_reader = each.value.robotic_users_reader
  users_owner          = each.value.users_owner
}

resource "aws_iam_group" "iam_groups" {
  for_each = { for key, group in var.iam_groups : key => group }
  name     = each.key
  path     = each.value.path
}

resource "aws_iam_policy" "iam_policies" {
  for_each = { for key, policy in var.iam_policies : key => policy }
  name     = each.key
  policy   = each.value
}

resource "aws_iam_group_policy_attachment" "group_policy" {
  depends_on = [resource.aws_iam_group.iam_groups, resource.aws_iam_policy.iam_policies]
  for_each   = { for key, data in local.groups_policies : key => data }

  group      = each.value.group
  policy_arn = each.value.policy
}

resource "aws_iam_user_policy_attachment" "user_policy" {
  depends_on = [module.iam_users, resource.aws_iam_policy.iam_policies]
  for_each   = { for key, data in local.users_policies : key => data }

  user       = each.value.user
  policy_arn = each.value.policy
}

resource "aws_iam_group_membership" "group" {
  depends_on = [module.iam_users, resource.aws_iam_group.iam_groups]
  for_each   = { for key, group in var.iam_groups : key => group if length(group.users) > 0 }

  name  = each.key
  group = each.key
  users = each.value.users
}
