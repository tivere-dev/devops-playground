#!/usr/bin/env bash
# recreate-deploy.sh <version> - the "Recreate" strategy: stop the old one, then start the new.
# Simple, but users get errors in between (downtime). Watch it with watch-traffic.sh.
set -euo pipefail
cd "$(dirname "$0")/.."
version="${1:?Usage: $0 <version>}"
active=$(./scripts/active-color.sh)
docker build -t "devops-app:$version" ./app
echo "Stopping app-$active (downtime starts now)..."
docker rm -f "app-$active"
docker run -d --name "app-$active" --network devops-net \
  -e COLOR="$active" -e VERSION="$version" --restart unless-stopped "devops-app:$version"
echo "Started $version in $active. Waiting for it to be healthy..."
until [[ "$(docker inspect --format '{{.State.Health.Status}}' "app-$active")" == "healthy" ]]; do sleep 2; done
# The new container has a new internal IP address, so tell nginx to look it up again
docker exec proxy nginx -s reload
echo "Back online (downtime over)."
