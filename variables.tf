variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "pgp_key" {
  description = "value of the pgp key to encrypt the secrets"
  type        = string
}
