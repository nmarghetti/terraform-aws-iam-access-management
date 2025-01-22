data "aws_iam_user" "iam_existing_user" {
  for_each  = var.iam_existing_users
  user_name = each.key
}

data "aws_iam_user" "iam_user" {
  depends_on = [module.iam_users]
  for_each   = var.iam_users
  user_name  = each.key
}

data "aws_iam_policy" "iam_policy" {
  depends_on = [resource.aws_iam_policy.iam_policies]
  for_each   = { for key, policy in var.iam_policies : key => policy }
  name       = each.key
}
