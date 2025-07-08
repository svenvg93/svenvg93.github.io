---
title: Portainer Series Part 2 | Updates with GitHub Actions & Tailscale  
description: Automate Docker updates with GitHub Actions, triggered securely over Tailscale.  
date: 07-07-2025  
categories:
  - DevOps
  - CI/CD
tags:
  - docker
  - tailscale
image:
  path: /assets/img/headers/2025-08-07-portainer-series-part-2-wehbooks-tailscale.jpg
  alt: Photo by Bernd Dittrich on Unsplash
---

In Part 2 of the Portainer Series, we’ll automate Docker stack updates using GitHub Actions and securely trigger deployments over your Tailscale network. This is ideal for managing self-hosted services with minimal manual overhead.

## Add Portainer to Tailscale

To allow GitHub secure access to Portainer, we’ll add it to our Tailscale network. This enables private, remote access from GitHub Actions.

### Docker Compose

In Part 1, we set up Portainer. Now, we’ll add Tailscale as a sidecar container to connect Portainer to your tailnet.

```yaml
# docker-compose.yml
services:
  portainer:
    image: portainer/portainer-ee:2.31.3
    container_name: portainer
    restart: unless-stopped
    environment:
      TZ: Europe/Amsterdam
      PUID: 1000
      PGID: 1000
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer:/data
    network_mode: service:tailscale
    depends_on:
      tailscale:
        condition: service_healthy

  tailscale:
    image: ghcr.io/tailscale/tailscale:v1.84.3
    container_name: tailscale-portainer
    restart: unless-stopped
    hostname: portainer
    environment:
      TZ: Europe/Amsterdam
      TS_AUTHKEY: ${TS_AUTHKEY}
      TS_STATE_DIR: /var/lib/tailscale
      TS_SERVE_CONFIG: /config/serve.json
      TS_USERSPAC: false
      TS_ENABLE_HEALTH_CHECK: true
      TS_LOCAL_ADDR_PORT: 127.0.0.1:41234
    volumes:
      - ./config:/config
      - tailscale-portainer:/var/lib/tailscale
    network_mode: bridge
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - net_admin
      - sys_module
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://127.0.0.1:41234/healthz"]
      interval: 1m
      timeout: 10s
      retries: 3
      start_period: 10s

volumes:
  portainer:
  tailscale-portainer:
```

### Generate a Tailscale Auth Key

To let the container authenticate with your Tailnet:

1. Visit [Tailscale Keys Page](https://login.tailscale.com/admin/settings/keys).
2. Click **Generate auth key**.
3. Fill out:
   - **Description**: A meaningful name
   - **Reusable**: Optional, depending on your use case
   - **Expiration**: Choose a suitable duration
4. Click **Generate Key** and copy the value.

Create a `.env` file next to `docker-compose.yml`:

```bash
nano .env
```

Add your key:

```env
TS_AUTHKEY=<your tailscale auth key>
```

### Serve Config

Create a `serve.json` file in a `config/` folder next to your `docker-compose.yml`. This tells Tailscale how to forward traffic to Portainer.

```json
{
  "TCP": {
    "443": {
      "HTTPS": true
    }
  },
  "Web": {
    "${TS_CERT_DOMAIN}:443": {
      "Handlers": {
        "/": {
          "Proxy": "http://127.0.0.1:9000"
        }
      }
    }
  }
}
```

Now, run the stack:

```bash
docker compose up -d
```

You’ll see the new Portainer device in your Tailscale admin panel and can access it via `https://portainer.funny-name.ts.net`.

## GitHub Actions for Stack Updates

Since [Dependabot](../dependabot-docker-compose) monitors your `docker-compose.yml` tags and creates PRs on updates, you can automate stack redeploys after merging those PRs.

Rather than polling Portainer, we’ll trigger a webhook via GitHub Actions.

### Create the GitHub Action

This workflow runs after pushing a tag or manually dispatching, extracts the tag (stack name), and triggers the corresponding webhook stored in GitHub Secrets.

```yaml
# .github/workflows/deploy-tag-webhook.yml
name: Deploy Stack via Portainer Webhook

on:
  push:
    tags:
      - '*'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Connect to Tailscale
        uses: tailscale/github-action@v3
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci

      - name: Extract stack from tag
        id: tag
        run: |
          STACK="${GITHUB_REF##refs/tags/}"
          echo "stack=$STACK" >> "$GITHUB_OUTPUT"

      - name: Trigger Portainer webhook
        run: |
          STACK="${{ steps.tag.outputs.stack }}"
          SECRET_NAME="PORTAINER_WEBHOOK_${STACK^^}"
          WEBHOOK_URL=$(printenv "$SECRET_NAME")

          if [ -z "$WEBHOOK_URL" ]; then
            echo "❌ No webhook URL found for stack '$STACK'"
            exit 1
          fi

          echo "✅ Triggering webhook for $STACK..."
          curl --fail --silent --show-error -X POST "$WEBHOOK_URL"
        env:
          PORTAINER_WEBHOOK_API: ${{ secrets.PORTAINER_WEBHOOK_API }}
          PORTAINER_WEBHOOK_FRONTEND: ${{ secrets.PORTAINER_WEBHOOK_FRONTEND }}
          PORTAINER_WEBHOOK_DB: ${{ secrets.PORTAINER_WEBHOOK_DB }}
```

### Get Tailscale OAuth Client ID and Secret

To authenticate the GitHub Action to your Tailscale network:

1. Go to the [Tailscale OAuth Clients Page](https://login.tailscale.com/admin/settings/oauth).
2. Click **Generate new client**.
3. Set:
   - **Name**: e.g., `GitHub Actions CI`
   - **Auth Keys**: make sure you select Write access to the Auth Keys
   - **Tags**: Apply the same tag used when generating the Tailscale Auth Key (e.g., tag:ci)
4. Copy the `Client ID` and `Client Secret`.
5. Add them as GitHub secrets:
   - `TS_OAUTH_CLIENT_ID`
   - `TS_OAUTH_SECRET`

### Create Secrets

Add secrets in your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**.
2. Click **New repository secret**.
3. Add:
   - `PORTAINER_WEBHOOK_API`
   - `PORTAINER_WEBHOOK_FRONTEND`
   - `PORTAINER_WEBHOOK_DB`
   - `TS_OAUTH_CLIENT_ID`
   - `TS_OAUTH_SECRET`

## Generate Workflow Automatically

You can automate the generation of `deploy-tag-webhook.yml` with the script below:

```bash
#!/bin/bash
set -euo pipefail

mkdir -p .github/workflows
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

# Discover stack folders by presence of docker-compose.yml
mapfile -t stacks < <(find . -maxdepth 2 -name 'docker-compose.yml' -exec dirname {} \; | sed 's|^\./||' | sort)

# Header
cat > "$tmpfile" <<'YAML'
name: Deploy Stack via Portainer Webhook

on:
  push:
    tags:
      - '*'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Connect to Tailscale
        uses: tailscale/github-action@v3
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci

      - name: Extract stack from tag
        id: tag
        run: |
          STACK="${GITHUB_REF##refs/tags/}"
          echo "Detected tag: \$STACK"
          echo "stack=\$STACK" >> "\$GITHUB_OUTPUT"

      - name: Trigger Portainer webhook
        run: |
          STACK="${{ steps.tag.outputs.stack }}"

          case "\$STACK" in
YAML

# Insert case entries for each stack
for stack in "${stacks[@]}"; do
  stack_clean=$(basename "$stack")
  secret_name="PORTAINER_WEBHOOK_${stack_clean//-/_}"
  secret_name="${secret_name^^}"
  cat >> "$tmpfile" <<YAML
            $stack_clean)
              WEBHOOK_URL="\${{ secrets.$secret_name }}"
              ;;
YAML
done

# Close case and run webhook trigger
cat >> "$tmpfile" <<'YAML'
            *)
              echo "❌ No known secret mapping for stack: $STACK"
              exit 1
              ;;
          esac

          echo "✅ Triggering webhook for $STACK..."
          curl --fail --silent --show-error -X POST "$WEBHOOK_URL"
YAML

# Install if changed
target=".github/workflows/deploy-tag-webhook.yml"
if ! [ -f "$target" ] || ! cmp -s "$tmpfile" "$target"; then
  mv "$tmpfile" "$target"
  echo "✅ Updated $target!"
else
  echo "ℹ️ No changes to $target."
fi
```
