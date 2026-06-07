variable "cloudflare_api_token" {
  description = "Cloudflare API token. Needs Account:Cloudflare Tunnel:Edit and Zone:DNS:Edit + Zone:Zone Settings:Edit on the deadrobot.online zone."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the deadrobot.online zone and will own the tunnel."
  type        = string
}

variable "cloudflare_zone_name" {
  description = "Cloudflare zone hosting the external service hostnames."
  type        = string
  default     = "deadrobot.online"
}

variable "tunnel_name" {
  description = "Name for the Cloudflare Tunnel created by this stack."
  type        = string
  default     = "media-center"
}
