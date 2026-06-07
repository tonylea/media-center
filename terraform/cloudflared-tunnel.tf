resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "media_center" {
  account_id    = var.cloudflare_account_id
  name          = var.tunnel_name
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
  config_src    = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "media_center" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.media_center.id

  config = {
    ingress = [
      {
        hostname = "plex.${var.cloudflare_zone_name}"
        service  = "http://plex:32400"
      },
      {
        hostname = "audiobookshelf.${var.cloudflare_zone_name}"
        service  = "http://audiobookshelf:80"
      },
      {
        hostname = "calibre.${var.cloudflare_zone_name}"
        service  = "http://calibre-web:8083"
      },
      {
        hostname = "komga.${var.cloudflare_zone_name}"
        service  = "http://komga:25600"
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "media_center" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.media_center.id
}
