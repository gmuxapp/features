# Dev Container Features for gmux

This repository contains [Dev Container Features](https://containers.dev/implementors/features/) for [gmux](https://gmux.app).

## Features

### `ghcr.io/gmuxapp/features/gmux`

Installs gmux and gmuxd into a dev container. gmuxd starts automatically when the container starts. The host gmuxd discovers it and aggregates its sessions into your dashboard.

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "ghcr.io/gmuxapp/features/gmux": {}
  }
}
```

That's it. No port forwarding or token configuration needed. See [src/gmux/README.md](src/gmux/README.md) for options, or the [Devcontainers guide](https://gmux.app/devcontainers) for the full walkthrough.

## Publishing

Features are published automatically to `ghcr.io/gmuxapp/features/` via the [release workflow](.github/workflows/release.yaml). Trigger it manually from the Actions tab after merging changes to `main`.
