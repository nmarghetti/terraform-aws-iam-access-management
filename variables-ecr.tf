variable "aws_ecr_repositories" {
  description = "List of AWS Elastic Container Registry to create."
  type = map(object({
    name                 = optional(string, null)
    image_tag_mutability = optional(string, "MUTABLE")
    force_destroy        = optional(bool, false)
  }))
  default = {}
}
