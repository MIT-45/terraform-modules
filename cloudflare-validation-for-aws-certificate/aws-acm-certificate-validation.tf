
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = var.certificate_arn
}
