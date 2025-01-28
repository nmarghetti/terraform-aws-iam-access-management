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

  lifecycle {
    precondition {
      condition     = length(local.groups_undefined) == 0
      error_message = "The following groups are not defined in the variable iam_groups: ${join(", ", local.groups_undefined)}. You are referencing groups in users that are not defined in the variable iam_groups."
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  depends_on = [module.iam_users, resource.aws_iam_group.iam_groups]
  for_each   = { for key, role in var.iam_roles : key => role if role.assume_role_policy == null }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = each.value.assume_role_principals != null ? each.value.assume_role_principals.type : "AWS"
      identifiers = each.value.assume_role_principals != null ? each.value.assume_role_principals.identifiers : concat(
        [for user in each.value.users : local.available_users[user].arn],
        [for group in each.value.groups : local.available_groups[group].arn],
      )
    }
  }
  lifecycle {
    precondition {
      condition = alltrue([
        # The error is not clear when checking that
        # # Ensure the user is referenced in the variable iam_users or iam_existing_users
        # length([for user in each.value.users : local.available_users[user].arn if contains(keys(local.available_users), user)]) == 0,
        # # Ensure the group is referenced in the variable iam_groups or iam_existing_groups
        # length([for group in each.value.groups : local.available_groups[group].arn if contains(keys(local.available_groups), group)]) == 0,
        length(concat(
          [for user in each.value.users : local.available_users[user].arn if contains(keys(local.available_users), user)],
          [for group in each.value.groups : local.available_groups[group].arn if contains(keys(local.available_groups), group)],
          each.value.assume_role_principals != null ? each.value.assume_role_principals.identifiers : []
        )) != 0
      ])
      error_message = "Missing role assume principals, you must at least set principal, users or groups. Users and groups must be either defined in the variable iam_users/iam_existing_users or iam_groups/iam_existing_groups."
    }
  }
}

resource "aws_iam_role" "iam_roles" {
  depends_on = [module.iam_users]
  for_each   = { for key, role in var.iam_roles : key => role }
  tags       = var.tags

  name               = each.key
  path               = each.value.path
  assume_role_policy = each.value.assume_role_policy != null ? each.value.assume_role_policy : data.aws_iam_policy_document.assume_role[each.key].json
}

resource "aws_iam_policy" "iam_policies" {
  for_each = { for key, policy in var.iam_policies : key => policy }
  tags     = var.tags
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

resource "aws_iam_role_policy_attachment" "role_policy" {
  depends_on = [resource.aws_iam_role.iam_roles, resource.aws_iam_policy.iam_policies]
  for_each   = { for key, data in local.roles_policies : key => data }

  role       = each.value.role
  policy_arn = each.value.policy
}

resource "aws_iam_group_membership" "group" {
  depends_on = [module.iam_users, resource.aws_iam_group.iam_groups]
  for_each   = { for group, users in local.groups_users : group => users }

  name  = each.key
  group = each.key
  users = each.value
}

resource "aws_ecr_repository" "ecr_repository" {
  for_each = { for key, ecr in var.aws_ecr_repositories : key => ecr }
  tags     = var.tags

  name                 = each.value.name != null ? each.value.name : each.key
  image_tag_mutability = each.value.image_tag_mutability
}
