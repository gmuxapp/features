#!/bin/bash
set -e

echo "Testing gmux installation..."

# Binaries exist
command -v gmux || { echo "FAIL: gmux not found"; exit 1; }
command -v gmuxd || { echo "FAIL: gmuxd not found"; exit 1; }

# Entrypoint script exists
test -x /usr/local/bin/gmuxd-start.sh || { echo "FAIL: gmuxd-start.sh not found"; exit 1; }

# Entrypoint sets GMUXD_LISTEN for container use
grep -q 'GMUXD_LISTEN' /usr/local/bin/gmuxd-start.sh \
  || { echo "FAIL: entrypoint missing GMUXD_LISTEN"; exit 1; }

# gmuxd can report its version
gmuxd version || { echo "FAIL: gmuxd version failed"; exit 1; }

# Entrypoint bakes in the remote user, not root (unless root IS the remote user)
if grep -q 'TARGET_USER="root"' /usr/local/bin/gmuxd-start.sh; then
  # Only acceptable if _REMOTE_USER was actually root
  echo "WARN: TARGET_USER is root; verify this is intentional"
else
  grep -q 'TARGET_USER=' /usr/local/bin/gmuxd-start.sh \
    || { echo "FAIL: entrypoint missing TARGET_USER"; exit 1; }
fi

echo "All tests passed!"
