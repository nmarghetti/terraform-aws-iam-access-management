variable "aws_secrets" {
  description = "Secret to be stored in AWS Secrets Manager"
  type = map(object({
    region               = string
    robotic_users_reader = list(string)
    users_owner          = list(string)
    secrets              = list(string)
  }))
  default = {}
}
