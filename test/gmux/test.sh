#!/bin/bash
set -e

echo "Testing gmux installation..."

# Binaries exist
command -v gmux || { echo "FAIL: gmux not found"; exit 1; }
command -v gmuxd || { echo "FAIL: gmuxd not found"; exit 1; }

# Entrypoint script exists
test -x /usr/local/bin/gmuxd-start.sh || { echo "FAIL: gmuxd-start.sh not found"; exit 1; }

# Default config was generated with network listener
grep -q 'listen = "0.0.0.0:8791"' /usr/local/share/gmux/config.toml \
  || { echo "FAIL: default config missing or wrong"; exit 1; }

# gmuxd can report its version
gmuxd version || { echo "FAIL: gmuxd version failed"; exit 1; }

echo "All tests passed!"
