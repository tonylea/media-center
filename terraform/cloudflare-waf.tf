resource "cloudflare_ruleset" "waf_managed" {
  zone_id     = data.cloudflare_zone.this.zone_id
  name        = "Managed WAF ruleset"
  description = "Deploy Cloudflare Free Managed Ruleset"
  kind        = "zone"
  phase       = "http_request_firewall_managed"

  rules = [
    {
      action      = "execute"
      expression  = "true"
      description = "Execute Cloudflare Free Managed Ruleset"
      enabled     = true
      action_parameters = {
        id = "77454fe2d30c4220b5701f6fdfb893ba"
      }
    }
  ]
}

resource "cloudflare_ruleset" "waf_custom" {
  zone_id     = data.cloudflare_zone.this.zone_id
  name        = "Custom WAF rules"
  description = "Custom WAF rules for media stack"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = "block"
      description = "Block common scanner and exploit paths"
      enabled     = true
      expression  = "(http.request.uri.path contains \"/wp-admin\" or http.request.uri.path contains \"/wp-login\" or http.request.uri.path contains \"/.env\" or http.request.uri.path contains \"/phpMyAdmin\" or http.request.uri.path contains \"/phpmyadmin\" or http.request.uri.path contains \"/actuator\" or http.request.uri.path contains \"/.git\" or http.request.uri.path contains \"/wp-content\" or http.request.uri.path contains \"/wp-includes\" or http.request.uri.path contains \"/xmlrpc.php\")"
    },
    {
      action      = "managed_challenge"
      description = "Challenge requests with high threat score"
      enabled     = true
      expression  = "(cf.threat_score gt 30)"
    },
    {
      action      = "block"
      description = "Block traffic from outside allowed countries"
      enabled     = true
      expression  = "(not ip.geoip.country in {\"GB\" \"AU\"})"
    }
  ]
}

resource "cloudflare_ruleset" "waf_rate_limit" {
  zone_id     = data.cloudflare_zone.this.zone_id
  name        = "Rate limiting rules"
  description = "Rate limit authentication endpoints"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules = [
    {
      action      = "block"
      description = "Rate limit login and auth endpoints"
      enabled     = true
      expression  = "(http.request.uri.path contains \"/login\" or http.request.uri.path contains \"/auth\" or http.request.uri.path contains \"/sign-in\" or http.request.uri.path contains \"/signin\")"
      ratelimit = {
        characteristics     = ["cf.colo.id", "ip.src"]
        period              = 10
        requests_per_period = 5
        mitigation_timeout  = 10
      }
    }
  ]
}
