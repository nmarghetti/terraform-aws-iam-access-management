locals {
  # All users/groups/policies to be created or existing, given in input
  input_users_name    = distinct(concat(keys(var.aws_iam_users), keys(var.aws_iam_existing_users)))
  input_groups_name   = distinct(concat(keys(var.aws_iam_groups), keys(var.aws_iam_existing_groups)))
  input_policies_name = distinct(concat(keys(var.aws_iam_policies), keys(var.aws_iam_existing_policies)))

  # All users/groups/policies created and retrieved from AWS
  available_users    = merge(data.aws_iam_user.iam_user, data.aws_iam_user.iam_existing_user)
  available_groups   = merge(resource.aws_iam_group.iam_groups, data.aws_iam_group.iam_existing_group)
  available_policies = merge(resource.aws_iam_policy.iam_policies, data.aws_iam_policy.iam_existing_policy)

  groups_policies = merge(
    # policies by arn
    { for data in flatten([
      for key, group in { for key, group in var.aws_iam_groups : key => {
        pair = [for policy in group.policy_arns : {
          group  = key
          policy = policy
        }]
      } } : group.pair
    ]) : "${data.group} - ${data.policy}" => data },
    # policies by name
    { for data in flatten([
      for key, group in { for key, group in var.aws_iam_groups : key => {
        pair = [for policy in group.policy_names : {
          group  = key
          name   = policy
          policy = local.available_policies[policy].arn
        }]
      } } : group.pair
    ]) : "${data.group} - ${data.name}" => data }
  )

  # Groups attached to users (either existing or to be created)
  groups_users_named = flatten([for raw_group in [
    transpose({ for key, user in var.aws_iam_users : key => user.groups }),
    transpose({ for key, user in var.aws_iam_existing_users : key => user.groups }),
    { for key, group in var.aws_iam_groups : key => group.users if length(group.users) > 0 }
  ] : [for group_name in keys(raw_group) : { name = group_name, users = raw_group[group_name] }]])
  groups_name  = distinct(flatten([for group in local.groups_users_named : group.name]))
  users_name   = distinct(flatten([for group in local.groups_users_named : group.users]))
  groups_users = { for group in local.groups_name : group => distinct(flatten([for group_users in local.groups_users_named : group_users.users if group_users.name == group])) }

  users_policies = merge(
    # policies by arn
    { for data in flatten([
      for key, user in { for key, user in var.aws_iam_existing_users : key => {
        pair = [for policy in user.policy_arns : {
          user   = key
          policy = policy
        }]
      } } : user.pair
    ]) : "${data.user} - ${data.policy}" => data },
    # policies by name
    { for data in flatten([
      for key, user in { for key, user in var.aws_iam_existing_users : key => {
        pair = [for policy in user.policy_names : {
          user   = key
          name   = policy
          policy = local.available_policies[policy].arn
        }]
      } } : user.pair
    ]) : "${data.user} - ${data.name}" => data }
  )

  roles_policies = merge(
    # policies by arn
    { for data in flatten([
      for key, role in { for key, role in var.aws_iam_roles : key => {
        pair = [for policy in role.policy_arns : {
          role   = key
          policy = policy
        }]
      } } : role.pair
    ]) : "${data.role} - ${data.policy}" => data },
    # policies by name
    { for data in flatten([
      for key, role in { for key, role in var.aws_iam_roles : key => {
        pair = [for policy in role.policy_names : {
          role   = key
          name   = policy
          policy = local.available_policies[policy].arn
        }]
      } } : role.pair
    ]) : "${data.role} - ${data.name}" => data }
  )

  policies_name = distinct(concat(
    flatten([for key, user in var.aws_iam_existing_users : [for policy in user.policy_names : policy]]),
    flatten([for key, role in var.aws_iam_roles : [for policy in role.policy_names : policy]])
  ))

  # Groups/users that has not been defined in the input
  groups_undefined   = [for group in local.groups_name : group if !contains(local.input_groups_name, group)]
  users_undefined    = [for user in local.users_name : user if !contains(local.input_users_name, user)]
  policies_undefined = [for policy in local.policies_name : policy if !contains(local.input_policies_name, policy)]
}
