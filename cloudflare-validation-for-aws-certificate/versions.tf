
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 4.30.0"
    }
  }
}
