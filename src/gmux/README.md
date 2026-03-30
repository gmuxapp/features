# gmux (ghcr.io/gmuxapp/features/gmux)

Installs [gmux](https://gmux.app) and gmuxd into a dev container. gmuxd starts automatically with `GMUXD_LISTEN=0.0.0.0` so it's accessible from the host via port forwarding.

## Usage

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "ghcr.io/gmuxapp/features/gmux:1": {}
  }
}
```

Port 8790 is automatically forwarded to the host. After the container starts, a clickable auth link appears in the terminal.

### Finding the auth token

```bash
gmuxd auth
```

Prints the listen address and a ready-to-use URL with the token. Open it in a browser to authenticate.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | gmux version to install (e.g. `0.8.0` or `latest`) |

## Security

All TCP connections use bearer token authentication. The token is auto-generated on first start and stored inside the container at `~/.local/state/gmux/auth-token`.

Devcontainer-aware tooling (VS Code, Codespaces) forwards the port to `localhost` on the host, so only local processes can reach it. The bearer token provides a second layer of protection on the Docker bridge network.

See [Network Listener](https://gmux.app/develop/network-listener) for the full security model.

## Peer discovery

A host gmuxd can automatically discover gmuxd instances running inside dev containers. No additional configuration is needed; the feature's presence in the container's `devcontainer.metadata` label is the discovery signal. See [Peer Discovery & Aggregation](https://gmux.app/planned/peer-discovery-aggregation) for details.
