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
  prefix               = each.value.resource_prefix
}
