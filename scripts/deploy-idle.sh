#!/usr/bin/env bash
# deploy-idle.sh <version> - build a new version and start it in the IDLE slot.
# Users don't see it yet: the proxy still points at the active slot.
set -euo pipefail
cd "$(dirname "$0")/.."

version="${1:-}"
if [[ -z "$version" ]]; then
  echo "Usage: $0 <version>   e.g. $0 v2" >&2
  exit 2
fi

active=$(./scripts/active-color.sh)
if [[ "$active" == "blue" ]]; then idle="green"; else idle="blue"; fi
echo "Active slot: $active  ->  deploying $version to idle slot: $idle"

docker build -t "devops-app:$version" ./app

docker rm -f "app-$idle" >/dev/null 2>&1 || true
docker run -d --name "app-$idle" --network devops-net \
  -e COLOR="$idle" -e VERSION="$version" --restart unless-stopped "devops-app:$version"

echo "Waiting for app-$idle to become healthy (uses the Dockerfile HEALTHCHECK)..."
for attempt in $(seq 1 30); do
  status=$(docker inspect --format '{{.State.Health.Status}}' "app-$idle")
  if [[ "$status" == "healthy" ]]; then
    echo "app-$idle is healthy after $attempt checks. Ready to switch with: ./scripts/switch.sh $idle"
    exit 0
  fi
  sleep 2
done

echo "app-$idle did not become healthy. NOT switching. Check: docker logs app-$idle" >&2
exit 1
