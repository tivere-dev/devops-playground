#!/usr/bin/env bash
# switch.sh <blue|green> - point 100% of traffic at one slot (the Blue/Green "flip")
set -euo pipefail

target="${1:-}"
if [[ "$target" != "blue" && "$target" != "green" ]]; then
  echo "Usage: $0 <blue|green>" >&2
  exit 2
fi

# Safety: never switch to a slot that isn't running
if [[ "$(docker inspect --format '{{.State.Running}}' "app-$target" 2>/dev/null)" != "true" ]]; then
  echo "app-$target is not running - refusing to switch." >&2
  exit 1
fi

# Write the new upstream into the proxy, test the config, then reload with zero downtime
docker exec -i proxy sh -c 'cat > /etc/nginx/active.conf' <<CONF
upstream app_backend {
    server app-$target:5000;
}
CONF
docker exec proxy nginx -t
docker exec proxy nginx -s reload
echo "Traffic now goes 100% to $target."
