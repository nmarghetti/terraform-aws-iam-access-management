output "aws_ecr_repositories" {
  description = "List of AWS Elastic Container Registry created."
  value       = resource.aws_ecr_repository.ecr_repository
}
