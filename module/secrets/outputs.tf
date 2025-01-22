output "role" {
  description = "Role that can read secrets from AWS Secrets Manager"
  value       = resource.aws_iam_role.robotic_user_assume_role
}

output "secrets" {
  description = "Secrets stored in AWS Secrets Manager"
  value       = resource.aws_secretsmanager_secret.secrets
}
