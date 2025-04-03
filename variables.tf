variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}
variable "worker_name" {
  type        = string
  default     = "spur-monocle"
  description = "Name for the Cloudflare Worker. Defaults to `spur-monocle`"
}
variable "routes" {
  type = list(object({
    pattern = string
    zone_id = string
  }))
  description = "List of routes on which to enable Monocle. Each item's properties are `pattern` and `zone_id`. Patterns must include your domain, e.g.: `example.com/*`. See https://developers.cloudflare.com/workers/configuration/routing/routes/#matching-behavior for more information"
}
variable "monocle_secret_key" {
  type        = string
  description = "Monocle Secret key"
  sensitive   = true
}
variable "monocle_cookie_secret" {
  type        = string
  description = "Optional override for the Cookie Secret. If empty, it defaults to a random hex string"
  sensitive   = true
  nullable    = true
  default     = null
}
variable "monocle_publishable_key" {
  type        = string
  description = "Monocle Publishable key"
}
variable "exempted_services" {
  type        = list(string)
  default     = []
  description = "Spur Service tags to exempt from blocking, e.g.: `['WARP_VPN', 'ICLOUD_RELAY_PROXY']`"
}
