#!/usr/bin/env bash
# status.sh - show what's running and where traffic goes
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
echo "== Containers =="
docker ps --filter "name=app-" --filter "name=proxy" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
echo
echo "== Proxy config (where traffic goes) =="
docker exec proxy cat /etc/nginx/active.conf
echo
echo "== Active slot: $(./scripts/active-color.sh)"
