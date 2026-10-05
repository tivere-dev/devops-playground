#!/usr/bin/env bash
# teardown.sh - remove the app containers and proxy (images and the network are kept)
set -uo pipefail
docker rm -f proxy app-blue app-green 2>/dev/null
echo "Removed proxy, app-blue, app-green."
