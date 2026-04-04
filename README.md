# Dev Container Features for gmux

This repository contains [Dev Container Features](https://containers.dev/implementors/features/) for [gmux](https://gmux.app).

## Features

### `ghcr.io/gmuxapp/features/gmux`

Installs gmux and gmuxd into a dev container. gmuxd starts automatically when the container starts.

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:debian",
  "features": {
    "ghcr.io/gmuxapp/features/gmux:1": {}
  },
  "forwardPorts": [8790]
}
```

See [src/gmux/README.md](src/gmux/README.md) for options and configuration.

## Publishing

Features are published automatically to `ghcr.io/gmuxapp/features/` via the [release workflow](.github/workflows/release.yaml). Trigger it manually from the Actions tab after merging changes to `main`.
