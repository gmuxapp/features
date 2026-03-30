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

# Entrypoint: starts gmuxd with GMUXD_LISTEN=0.0.0.0 so the container
# is reachable via port forwarding. No config file needed.
# _REMOTE_USER and _REMOTE_USER_HOME are available at build time (install.sh)
# but NOT at container start. Bake them into the entrypoint script now.
REMOTE_USER="${_REMOTE_USER:-root}"
REMOTE_HOME="${_REMOTE_USER_HOME:-/root}"

cat > /usr/local/bin/gmuxd-start.sh << SCRIPT
#!/bin/bash
TARGET_USER="${REMOTE_USER}"
TARGET_HOME="${REMOTE_HOME}"
export GMUXD_LISTEN="0.0.0.0"

# Start gmuxd as the remote user so state (auth token, db) lives in their home.
start_gmuxd() {
  if [ "\$(id -u)" = "0" ] && [ "\$TARGET_USER" != "root" ] && id "\$TARGET_USER" &>/dev/null; then
    su - "\$TARGET_USER" -c "GMUXD_LISTEN=0.0.0.0 gmuxd start" >/tmp/gmuxd.log 2>&1 &
  else
    gmuxd start >/tmp/gmuxd.log 2>&1 &
  fi
}

SOCK="\${TARGET_HOME}/.local/state/gmux/gmuxd.sock"
if ! curl -fsS --unix-socket "\$SOCK" http://localhost/v1/health >/dev/null 2>&1; then
  start_gmuxd
  for i in \$(seq 1 30); do
    curl -fsS --unix-socket "\$SOCK" http://localhost/v1/health >/dev/null 2>&1 && break
    sleep 0.5
  done
fi
exec "\$@"
SCRIPT
chmod +x /usr/local/bin/gmuxd-start.sh

# Post-attach notice: prints a localhost auth URL that's clickable in the
# VS Code terminal. Runs as the remote user after VS Code attaches.
cat > /usr/local/bin/gmuxd-auth-notice.sh << 'NOTICE'
#!/bin/bash
TOKEN_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/gmux/auth-token"
if [ -f "$TOKEN_FILE" ]; then
  TOKEN=$(cat "$TOKEN_FILE")
  URL="http://localhost:8790/auth/login?token=${TOKEN}"
  VERSION=$(gmuxd version 2>/dev/null || echo "unknown")
  CHANGELOG="https://gmux.app/changelog"
  echo ""
  printf '  \e[1;36m\e]8;;%s\007Open gmux\e]8;;\007\e[0m\n' "$URL"
  echo ""
  printf '  Version %s \xc2\xb7 \e]8;;%s\007Changelog\e]8;;\007\n' "$VERSION" "$CHANGELOG"
  echo ""
fi
NOTICE
chmod +x /usr/local/bin/gmuxd-auth-notice.sh
