# media-center

Docker Compose stack running a handful of media servers behind a local Traefik reverse proxy and a Cloudflare Tunnel.
Provisions its own Cloudflare resources with Terraform.

## Layout

`docker-compose.yml` runs the services.
`traefik/` is the reverse-proxy config.
`terraform/` provisions the Cloudflare Tunnel, DNS, and WAF.
`.env` holds runtime secrets and is never committed — see `.env.example` for the keys it needs.
Persistent state lives under `DATA_ROOT`.

## Day to day

```sh
# Bring everything up / down.
docker compose up -d
docker compose down

# Logs.
docker compose logs -f <service>

# Restart one service after editing its config or compose entry.
docker compose up -d --no-deps --force-recreate <service>

# Pull newer images (services are pinned where stability matters; latest where it doesn't).
docker compose pull && docker compose up -d
```

## When something breaks

Traefik issuing certs: look at `${DATA_ROOT}/traefik/letsencrypt/acme.json` and `docker compose logs traefik`.
The cert is issued via Cloudflare DNS-01 against a delegated zone — if renewals fail, check the Cloudflare API token in `.env` hasn't expired.

External access broken: `docker compose logs cloudflared` — look for "Registered tunnel connection".
If the tunnel isn't connecting, the most common cause is a stale `TUNNEL_TOKEN` in `.env` after a tunnel was re-created in Terraform.

Internal access broken: it's probably DNS or Traefik.
`curl -v` from the host against the service hostname will tell you which.

Media mount empty inside a container: Docker Desktop's File Sharing list no longer includes the volume path.
Settings → Resources → File Sharing.

## Editing infrastructure

Terraform reads its inputs from `TF_VAR_*` entries in `.env`, so export them first:

```sh
set -a && source .env && set +a
cd terraform
terraform plan
terraform apply
```

If Terraform rotates the tunnel, refresh the token in `.env`:

```sh
terraform -chdir=terraform output -raw cloudflared_tunnel_token > /tmp/token
# update TUNNEL_TOKEN in .env, then:
docker compose up -d cloudflared
```

## Adding a service

Add a service block to `docker-compose.yml` with Traefik labels for the internal hostname.
If it also needs external access, add an `ingress` entry in `terraform/cloudflared-tunnel.tf` and a CNAME in `terraform/cloudflare-dns.tf`, then `terraform apply`.
