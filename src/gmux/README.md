# gmux (ghcr.io/gmuxapp/features/gmux)

Installs [gmux](https://gmux.app) and gmuxd into a dev container. gmuxd starts automatically and listens on all interfaces so it's accessible via port forwarding.

## Usage

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "ghcr.io/gmuxapp/features/gmux:1": {}
  }
}
```

Port 8790 is automatically forwarded to the host. Open the forwarded URL and authenticate with the bearer token.

### Finding the auth token

```bash
docker exec <container> gmuxd auth
```

Prints the listen address, auth token, and a ready-to-use login URL.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | gmux version to install (e.g. `0.8.0` or `latest`) |

## Pre-provisioned auth token

If you need a known token (for scripting, health checks, or future host-side peer discovery), set `GMUXD_TOKEN` in your `devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "ghcr.io/gmuxapp/features/gmux:1": {}
  },
  "containerEnv": {
    "GMUXD_TOKEN": "output-of-openssl-rand-hex-32"
  }
}
```

The token must be at least 64 hex characters. On first start, gmuxd writes it to disk. On subsequent starts, the file is verified against the env var. See [Environment variables](https://gmux.app/reference/environment/#auth-token) for details.

## Security

The network listener requires bearer token authentication on every request. The token is auto-generated on first start and stored inside the container at `~/.local/state/gmux/auth-token`.

Devcontainer-aware tooling (VS Code, Codespaces) forwards the port to `localhost` on the host, so only local processes can reach it. The bearer token provides a second layer of protection on the Docker bridge network.

See [Security](https://gmux.app/security/) for the full security model.

## How it works

The feature sets `GMUXD_LISTEN=0.0.0.0` via `containerEnv` so gmuxd accepts connections from outside the container (required for port forwarding and Docker bridge access). The entrypoint starts gmuxd in the background before running the container's main process.

## Peer discovery

A host gmuxd will be able to automatically discover gmuxd instances running inside dev containers. The feature's presence in the container's `devcontainer.metadata` label is the discovery signal. See [Peer Discovery & Aggregation](https://gmux.app/planned/peer-discovery-aggregation/) for the planned design.
