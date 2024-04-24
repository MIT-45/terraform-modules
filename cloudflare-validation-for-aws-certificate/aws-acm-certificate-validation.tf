
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = var.certificate_arn

  depends_on = [
    cloudflare_record.validation
  ]
}
