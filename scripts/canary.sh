#!/usr/bin/env bash
# canary.sh <new-color> <percent> - send only <percent>% of traffic to the new slot
# Example: ./scripts/canary.sh green 10   -> 90% stays on blue, 10% tries green
set -euo pipefail

new="${1:-}"; percent="${2:-}"
if [[ "$new" != "blue" && "$new" != "green" ]] || [[ ! "$percent" =~ ^[0-9]+$ ]] || (( percent < 1 || percent > 99 )); then
  echo "Usage: $0 <blue|green> <1-99>" >&2
  exit 2
fi
if [[ "$new" == "blue" ]]; then old="green"; else old="blue"; fi

for c in "$old" "$new"; do
  if [[ "$(docker inspect --format '{{.State.Running}}' "app-$c" 2>/dev/null)" != "true" ]]; then
    echo "app-$c must be running for a canary." >&2
    exit 1
  fi
done

docker exec -i proxy sh -c 'cat > /etc/nginx/active.conf' <<CONF
upstream app_backend {
    server app-$old:5000 weight=$((100 - percent));
    server app-$new:5000 weight=$percent;
}
CONF
docker exec proxy nginx -t
docker exec proxy nginx -s reload
echo "Canary on: $((100 - percent))% -> $old, $percent% -> $new"
