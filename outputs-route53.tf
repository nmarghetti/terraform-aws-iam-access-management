output "aws_route53_zones" {
  description = "List of route53 zones"
  value       = resource.aws_route53_zone.route53_zone
}

output "aws_acm_certificates" {
  description = "List of ACM certificates"
  value       = resource.aws_acm_certificate.certificate
}

output "aws_route53_record" {
  description = "List of route53 records"
  value       = resource.aws_route53_record.route53_record
}
