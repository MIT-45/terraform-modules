

resource "cloudflare_record" "validation" {
  #   for_each = {for k, v aws_acm_certificate.staging.domain_validation_options : k => v.domain_name}
  for_each = local.staging_certificate_domain_validation_records

  # get zone_id from map and using regex match
  zone_id = lookup(var.root_domain_to_zone_id_map, each.value.domain_root)
  name = each.value.record_name
  type = each.value.record_type
  value = each.value.record_value
  # 5 min ttl
  ttl = 300
  # not proxied
  proxied = false

  allow_overwrite = true

}