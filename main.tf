locals {
  # If the user does not supply var.secret, use the Terraform-generated random string
  effective_secret = var.monocle_cookie_secret != null ? var.monocle_cookie_secret : random_string.cookie_secret_hex.result

  # Convert the list of strings into "quoted,quoted,quoted" for JavaScript
  exempted_services_js = join(", ", formatlist("\"%s\"", var.exempted_services))

  # Perform the actual replace with our compiled exempted services list
  final_worker_js = replace(
    file("${path.module}/worker.js.template"),
    "<EXEMPTED_SERVICES_PLACEHOLDER>",
    "[${local.exempted_services_js}]" # the actual JS array
  )
}

resource "random_string" "cookie_secret_hex" {
  length  = 64
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "cloudflare_workers_kv_namespace" "monocle" {
  account_id = var.cloudflare_account_id
  title      = "monocle_worker_kv"
}

resource "cloudflare_workers_kv" "captcha_page" {
  account_id   = var.cloudflare_account_id
  namespace_id = cloudflare_workers_kv_namespace.monocle.id
  key          = "CAPTCHA_CONTENT"
  value        = file("${path.module}/captcha.html")
}

resource "cloudflare_workers_script" "monocle" {
  account_id = var.cloudflare_account_id
  name       = var.worker_name
  content    = local.final_worker_js
  #content = file("${path.module}/worker.js")
  module = true


  kv_namespace_binding {
    name         = cloudflare_workers_kv_namespace.monocle.title
    namespace_id = cloudflare_workers_kv_namespace.monocle.id
  }
}

resource "cloudflare_worker_route" "routes" {
  for_each = { for idx, route in var.routes : idx => route }

  zone_id     = each.value.zone_id
  pattern     = each.value.pattern
  script_name = cloudflare_workers_script.monocle.name
}

resource "cloudflare_worker_secret" "monocle_secret_key" {
  account_id  = var.cloudflare_account_id
  name        = "SECRET_KEY"
  script_name = cloudflare_workers_script.monocle.name
  secret_text = var.monocle_secret_key
}

resource "cloudflare_worker_secret" "monocle_publishable_key" {
  account_id  = var.cloudflare_account_id
  name        = "PUBLISHABLE_KEY"
  script_name = cloudflare_workers_script.monocle.name
  secret_text = var.monocle_publishable_key
}

resource "cloudflare_worker_secret" "monocle_cookie_secret" {
  account_id  = var.cloudflare_account_id
  name        = "COOKIE_SECRET_VALUE"
  script_name = cloudflare_workers_script.monocle.name
  secret_text = local.effective_secret
}
