resource "aws_route53_zone" "route53_zone" {
  for_each = { for zone_name, zone in var.aws_route53_zone : zone_name => zone }

  tags    = merge(var.tags, { Name = each.key })
  name    = each.value.domain
  comment = each.value.comment
}

resource "aws_acm_certificate" "certificate" {
  depends_on = [resource.aws_route53_zone.route53_zone]
  for_each = { for cert in flatten([for zone_name, zone in var.aws_route53_zone : [
    for certificate_name, certificate in zone.certificates : merge(certificate, { name = certificate_name, zone = zone_name })
  ]]) : "${cert.zone} - ${cert.name}" => cert }

  tags                      = merge(var.tags, { Name = each.key })
  domain_name               = each.value.domain
  subject_alternative_names = each.value.alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route53_record" {
  depends_on = [resource.aws_acm_certificate.certificate]
  for_each = { for record_data in flatten([for record in { for cert in flatten([for zone_name, zone in var.aws_route53_zone : [
    for certificate_name, certificate in zone.certificates : merge(certificate, { name = certificate_name, zone = zone_name })
    ]]) : "${cert.zone} - ${cert.name}" => [
    for validation in resource.aws_acm_certificate.certificate["${cert.zone} - ${cert.name}"].domain_validation_options : merge(validation, { zone = cert.zone, cert = cert.name })
  ] } : record]) : "${record_data.zone} - ${record_data.cert} - ${record_data.domain_name}" => record_data }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 120
  type            = each.value.resource_record_type
  zone_id         = aws_route53_zone.route53_zone[each.value.zone].zone_id
}
