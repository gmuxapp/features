#!/bin/bash
set -e

# Ensure curl is available (minimal base images like ubuntu:latest don't have it)
if ! command -v curl &>/dev/null; then
  apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*
fi

VERSION="${VERSION:-latest}"
ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m)"

# Normalize architecture
case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# Resolve "latest" to an actual version
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -fsSL https://api.github.com/repos/gmuxapp/gmux/releases/latest \
    | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
  VERSION="${VERSION#v}"
fi

echo "Installing gmux ${VERSION} (${ARCH})..."

URL="https://github.com/gmuxapp/gmux/releases/download/v${VERSION}/gmux_${VERSION}_linux_${ARCH}.tar.gz"
curl -fsSL "$URL" | tar xz -C /usr/local/bin/ gmux gmuxd

# Verify
if ! command -v gmux &>/dev/null || ! command -v gmuxd &>/dev/null; then
  echo "Error: gmux installation failed" >&2
  exit 1
fi

echo "gmux ${VERSION} installed successfully"

# Entrypoint: starts gmuxd if not already running.
# gmuxd start backgrounds itself, logs to ~/.local/state/gmux/gmuxd.log,
# and waits for health before returning.
# GMUXD_LISTEN is set via containerEnv in devcontainer-feature.json.
# GMUXD_TOKEN can be set via containerEnv in the user's devcontainer.json.
cat > /usr/local/bin/gmuxd-start.sh << 'SCRIPT'
#!/bin/bash
if ! gmuxd status >/dev/null 2>&1; then
  gmuxd start
fi
exec "$@"
SCRIPT
chmod +x /usr/local/bin/gmuxd-start.sh
