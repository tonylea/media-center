output "cloudflared_tunnel_id" {
  description = "ID of the Cloudflare Tunnel that fronts the media services."
  value       = cloudflare_zero_trust_tunnel_cloudflared.media_center.id
}

output "cloudflared_tunnel_token" {
  description = "Token used by the local cloudflared container to authenticate. Copy into .env as TUNNEL_TOKEN."
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.media_center.token
  sensitive   = true
}
