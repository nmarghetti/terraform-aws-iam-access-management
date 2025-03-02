variable "aws_route53_zone" {
  description = "List of AWS route53 zone to create."
  type = map(object({
    domain  = string
    comment = optional(string, "")
    certificates = optional(map(object({
      domain            = string
      alternative_names = optional(list(string), [])
    })), {})
  }))
  default = {}
}
