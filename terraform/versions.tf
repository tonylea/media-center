terraform {
  required_version = ">= 1.14"

  cloud {
    organization = "deadrobot"

    workspaces {
      name = "media-center"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
