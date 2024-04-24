
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = var.certificate_arn
  validation_record_fqdns = [
    for record in cloudflare_record.validation :
      record.hostname
  ]
}
