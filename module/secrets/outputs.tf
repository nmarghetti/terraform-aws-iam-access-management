output "role" {
  description = "Role that can read secrets from AWS Secrets Manager"
  value       = resource.aws_iam_role.robotic_user_assume_role
}

output "assume_role" {
  description = "Assume role to allow robotic user to acces secrets"
  value       = resource.aws_iam_role.robotic_user_assume_role
}

output "secrets" {
  description = "Secrets stored in AWS Secrets Manager"
  value       = resource.aws_secretsmanager_secret.secrets
}

output "role_policy_attachement" {
  description = "AWS policy attachement to role"
  value       = resource.aws_iam_role_policy_attachment.secrets_attach
}

output "user_policy_attachement" {
  description = "AWS policy attachement to user"
  value       = resource.aws_iam_role_policy_attachment.secrets_attach
}
