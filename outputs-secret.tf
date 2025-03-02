output "aws_secrets" {
  description = "AWS secrets"
  value = {
    for key, secret in module.secrets : key => {
      secrets = secret.secrets
      role    = secret.role
    }
  }
}
