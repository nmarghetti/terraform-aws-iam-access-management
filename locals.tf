locals {
  available_users  = merge(data.aws_iam_user.iam_user, data.aws_iam_user.iam_existing_user)
  available_groups = merge(resource.aws_iam_group.iam_groups, data.aws_iam_group.iam_existing_group)

  groups_policies = merge(
    # policies by arn
    { for data in flatten([
      for key, group in { for key, group in var.iam_groups : key => {
        pair = [for policy in group.policy_arns : {
          group  = key
          policy = policy
        }]
      } } : group.pair
    ]) : "${data.group} - ${data.policy}" => data },
    # policies by name
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

  groups_users_named = flatten([for raw_group in [
    transpose({ for key, user in var.iam_users : key => user.groups }),
    transpose({ for key, user in var.iam_existing_users : key => user.groups }),
    { for key, group in var.iam_groups : key => group.users if length(group.users) > 0 }
  ] : [for group_name in keys(raw_group) : { name = group_name, users = raw_group[group_name] }]])
  groups_name      = distinct(flatten([for group in local.groups_users_named : group.name]))
  groups_undefined = [for group in local.groups_name : group if !contains(keys(var.iam_groups), group)]
  groups_users     = { for group in local.groups_name : group => flatten([for group_users in local.groups_users_named : group_users.users if group_users.name == group]) }

  users_policies = merge(
    # policies by arn
    { for data in flatten([
      for key, user in { for key, user in var.iam_existing_users : key => {
        pair = [for policy in user.policy_arns : {
          user   = key
          policy = policy
        }]
      } } : user.pair
    ]) : "${data.user} - ${data.policy}" => data },
    # policies by name
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

  roles_policies = merge(
    # policies by arn
    { for data in flatten([
      for key, role in { for key, role in var.iam_roles : key => {
        pair = [for policy in role.policy_arns : {
          role   = key
          policy = policy
        }]
      } } : role.pair
    ]) : "${data.role} - ${data.policy}" => data },
    # policies by name
    { for data in flatten([
      for key, role in { for key, role in var.iam_roles : key => {
        pair = [for policy in role.policy_names : {
          role   = key
          name   = policy
          policy = data.aws_iam_policy.iam_policy[policy].arn
        }]
      } } : role.pair
    ]) : "${data.role} - ${data.name}" => data }
  )
}
