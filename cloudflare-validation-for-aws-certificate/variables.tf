
variable "certificate_arn" {
  type = string
}

variable "domain_validation_options" {
  type = set(object({
    domain_name = string
    resource_record_name = string
    resource_record_type = string
    resource_record_value = string
  }))
}

variable "root_domain_to_zone_id_map" {
  type = map(string)
}

locals {
  # regex to get root domain from subdomain
  domain_to_root_regex = "[^\\.]*\\.[^\\.]*$"
}

locals {
  # cleaned up options for each validation
  validation_options = [
    for domain_validation in var.domain_validation_options:
    tomap({
      domain_root = try(regex(local.domain_to_root_regex, domain_validation.domain_name), null)
      domain_name  = domain_validation.domain_name
      record_name  = domain_validation.resource_record_name
      record_type  = domain_validation.resource_record_type
      record_value = domain_validation.resource_record_value
    })
    if try(regex(local.domain_to_root_regex, domain_validation.domain_name), null) != null
  ]
  # record names that should be created
  validation_record_names = [
    for option in local.validation_options:
    option.record_name
  ]
  # distinct record names that should be created
  validation_record_names_distinct = distinct(local.validation_record_names)

  staging_certificate_domain_validation_records = {
    for validation_record_name in local.validation_record_names_distinct:
    validation_record_name => element(local.validation_options, index(local.validation_record_names, validation_record_name))
  }
}