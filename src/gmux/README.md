# gmux (ghcr.io/gmuxapp/features/gmux)

Installs [gmux](https://gmux.app) and gmuxd into a dev container. gmuxd starts automatically when the container starts. The host gmuxd discovers it and aggregates its sessions into your dashboard.

## Usage

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "ghcr.io/gmuxapp/features/gmux": {}
  }
}
```

That's it. Rebuild the container, start a `gmux` session inside it, and it shows up on the host. No port forwarding, no token copying.

The host gmuxd detects the container via Docker events, reads the auth token via `docker exec`, and connects over the Docker bridge. See [Devcontainers](https://gmux.app/devcontainers) for the full guide.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | gmux version to install (e.g. `1.0.0` or `latest`) |

## Pre-provisioned auth token

If you need a known token (for scripting or health checks), set `GMUXD_TOKEN` in your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/gmuxapp/features/gmux": {}
  },
  "containerEnv": {
    "GMUXD_TOKEN": "output-of-openssl-rand-hex-32"
  }
}
```

The token must be at least 64 hex characters. On first start, gmuxd writes it to disk. On subsequent starts, the file is verified against the env var. See [Environment variables](https://gmux.app/reference/environment/#auth-token) for details.

With auto-discovery you rarely need this; the host reads the token from the container automatically.

## Standalone access

If there's no host-side gmux (e.g. a remote server), add port forwarding to access the container's UI directly:

```json
{
  "features": {
    "ghcr.io/gmuxapp/features/gmux": {}
  },
  "forwardPorts": [8790],
  "portsAttributes": {
    "8790": { "label": "gmux", "onAutoForward": "silent" }
  }
}
```

Authenticate with `docker exec <container> gmuxd auth`.

## Security

The network listener requires bearer token authentication on every request. The token is auto-generated on first start and stored inside the container at `~/.local/state/gmux/auth-token`.

The host gmuxd reads this token via `docker exec` and uses it to authenticate. No secrets leave the Docker bridge network.

See [Security](https://gmux.app/security/) for the full security model.

## How it works

The feature sets `GMUXD_LISTEN=0.0.0.0` via `containerEnv` so gmuxd accepts connections from outside the container (required for Docker bridge access). The entrypoint runs `gmuxd start` before the container's main process. The host gmuxd subscribes to Docker events and detects containers with `GMUXD_LISTEN` in their environment.
