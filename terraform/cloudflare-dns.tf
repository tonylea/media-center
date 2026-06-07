locals {
  tunnel_cname_target = "${cloudflare_zero_trust_tunnel_cloudflared.media_center.id}.cfargotunnel.com"

  # External hostnames routed through the tunnel. Jellyfin is deliberately
  # excluded — internal-only by design.
  tunnel_routes = toset([
    "plex",
    "audiobookshelf",
    "calibre",
    "komga",
  ])
}

resource "cloudflare_dns_record" "tunnel_cname" {
  for_each = local.tunnel_routes

  zone_id = data.cloudflare_zone.this.zone_id
  name    = each.value
  type    = "CNAME"
  content = local.tunnel_cname_target
  proxied = true
  ttl     = 1
}
