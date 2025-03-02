data "aws_caller_identity" "current" {}

#### RETRIEVE ROBOTIC USERS THAT CAN ACCESS SECRETS ####

data "aws_iam_user" "robotic_users" {
  for_each  = { for user in var.robotic_users_reader : user => user }
  user_name = each.key
}

#### RETRIEVE USERS THAT CAN MANAGE SECRETS ####

data "aws_iam_user" "users" {
  for_each  = { for user in var.users_owner : user => user }
  user_name = each.key
}

#### CREATE ROLE TO ACCESS SECRETS ####

data "aws_iam_policy_document" "robotic_user_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for user in data.aws_iam_user.robotic_users : user.arn]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "robotic_user_assume_role" {
  name               = "aws_secret_assume_for_${var.secret_project_name}"
  assume_role_policy = data.aws_iam_policy_document.robotic_user_assume_role.json
  tags               = var.tags
}

#### CREATE SECRETS ####

data "aws_iam_policy_document" "secrets_restriction" {
  statement {
    effect = "Deny"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values = concat(
        [for user in data.aws_iam_user.users : user.arn],
        [for robot in data.aws_iam_user.robotic_users : robot.arn],
        ["arn:aws:*::${local.aws_account_id}:*/${var.secret_project_name}"],
      )
    }
  }
  statement {
    effect = "Deny"
    actions = [
      "secretsmanager:PutResourcePolicy"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["*"]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values = distinct(concat(
        [for user in data.aws_iam_user.users : user.arn],
        [data.aws_caller_identity.current.arn],
      ))
    }
  }
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(var.secrets)
  name     = "${var.secret_project_name}-${each.value}"
  tags     = var.tags
  policy   = data.aws_iam_policy_document.secrets_restriction.json
}


#### ATTACH POLICY TO ACCESS SECRET FOR ROBOTIC USERS/ROLES ####

data "aws_iam_policy_document" "secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = ["arn:aws:secretsmanager:${var.region}:${local.aws_account_id}:secret:${var.secret_project_name}-*"]
  }
}

resource "aws_iam_policy" "secrets" {
  name        = "aws_secret_access_to_${var.secret_project_name}"
  description = "Secrets policy for ${var.secret_project_name}"
  policy      = data.aws_iam_policy_document.secrets.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_attach" {
  role       = aws_iam_role.robotic_user_assume_role.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_iam_user_policy_attachment" "secrets_attach" {
  for_each   = data.aws_iam_user.robotic_users
  user       = each.value.user_name
  policy_arn = aws_iam_policy.secrets.arn
}
