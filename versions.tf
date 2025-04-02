terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      # current blockers to upgrading to version 5
      # https://github.com/cloudflare/terraform-provider-cloudflare/issues/5352
      # https://github.com/cloudflare/terraform-provider-cloudflare/issues/5134
      version = "~> 4"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}