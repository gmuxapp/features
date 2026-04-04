#!/bin/bash
set -e

echo "Testing gmux installation..."

# Binaries exist
command -v gmux || { echo "FAIL: gmux not found"; exit 1; }
command -v gmuxd || { echo "FAIL: gmuxd not found"; exit 1; }

# Entrypoint script exists and is executable
test -x /usr/local/bin/gmuxd-start.sh || { echo "FAIL: gmuxd-start.sh not found or not executable"; exit 1; }

# GMUXD_LISTEN is set via containerEnv
test "$GMUXD_LISTEN" = "0.0.0.0" || { echo "FAIL: GMUXD_LISTEN not set (got: '$GMUXD_LISTEN')"; exit 1; }

# gmuxd can report its version
gmuxd version || { echo "FAIL: gmuxd version failed"; exit 1; }

echo "All tests passed!"
