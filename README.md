# Terraform Module for Spur Monocle Cloudflare Worker

This is a Terraform module that will deploy Spur's [Monocle passive VPN and Proxy-blocking captcha](https://spur.us/monocle/) to a Cloudflare Worker.

You can learn more about Monocle in our [official docs](https://docs.spur.us/monocle).

## Usage

### Cloudflare API Token

You'll need a Cloudflare API Token with the correct permissions.

Go to the [API Tokens dashboard](https://dash.cloudflare.com/profile/api-tokens) and create a new API Token.

Select the `Edit Cloudflare Workers` permissions template. You'll also have to select the specific `Account Resources` and `Zone Resources` you'll be using, or just select "All Accounts" and "All Zones" in the respective dropdowns.

### Cloudflare Account ID

You'll need your Cloudflare account ID. This is the the alphanumeric string in URL when you are signed in to the Cloudflare dashboard, or you can find it in the `Account ID` widget on the right side of any of your zone (domain) pages.

### Cloudflare Zone ID(s)

You'll also need the Zone ID from the Cloudlare Zone resources you wish to deploy Monocle to. You can find this above the `Account ID` widget mentioned in the previous step. You can protect multiple Zones with this Worker.

### Monocle Secrets and Tokens

Log in to your [Spur dashboard](https://app.spur.us/monocle) to create a free Monocle deployment. You may also use the values from an existing deployment.

You'll need the values for `Publishable key` and `Secret key`.

### Deployment

Set up your API Token in your Terraform environment using either environment variables, tfvars file, or the command line. [Read more about Terraform variables here](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables).

```bash
export TF_VAR_cloudflare_api_token=<your API token>
```

Below is a full example of usage of this Terraform module for the site `mcl-test.com`

```terraform
# Due to a number of bugs in the 5th version of the Cloudflare official provider, you must use the 4th version for now.
# When these bugs are fixed, we will update this repo to use the latest version of the provider.
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare API Token"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "monocle_worker" {
  source = "git::git@github.com:spurintel/terraform-cloudflare-worker-spur-monocle"

  cloudflare_account_id   = "<your Cloudflare Account ID>"
  monocle_secret_key      = "<your Monocle Secret key>"
  monocle_publishable_key = "<your Monocle Publishable key>"

  # Add each zone/route combination you wish for Monocle to protect here
  # You may have as many zones and routes protected as you wish
  # Note that you _must_ include the domain name in the pattern
  # You may also use wildcards, see: https://developers.cloudflare.com/workers/configuration/routing/routes/#matching-behavior
  routes = [
    {
      pattern = "mcl-test.com/*"
      zone_id = "<Zone ID for mcl-test.com>"
    }
  ]

  # Any services that you wish to allow through to your website, you may define them here
  # These are the Spur service tags that can be found here: https://docs.spur.us/service-tags
  exempted_services = [
    "MULLVAD_VPN",
    "WARP_VPN",
    "PROTON_VPN"
  ]
}
```
