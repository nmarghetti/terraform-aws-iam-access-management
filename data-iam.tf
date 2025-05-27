data "aws_iam_user" "iam_existing_user" {
  for_each  = var.aws_iam_existing_users
  user_name = each.key
}

data "aws_iam_user" "iam_user" {
  depends_on = [module.iam_users]
  for_each   = var.aws_iam_users
  user_name  = each.key
}

data "aws_iam_group" "iam_existing_group" {
  for_each   = var.aws_iam_existing_groups
  group_name = each.key
}

data "aws_iam_policy" "iam_existing_policy" {
  for_each = var.aws_iam_existing_policies
  name     = each.key
}
