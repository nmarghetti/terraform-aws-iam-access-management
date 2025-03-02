resource "aws_ecr_repository" "ecr_repository" {
  for_each = { for key, ecr in var.aws_ecr_repositories : key => ecr }
  tags     = var.tags

  name                 = each.value.name != null ? each.value.name : each.key
  image_tag_mutability = each.value.image_tag_mutability
}
