#!/usr/bin/env bash
# rollback.sh - instantly send traffic back to the other slot (the old version is still running)
set -euo pipefail
cd "$(dirname "$0")/.."
active=$(./scripts/active-color.sh)
if [[ "$active" == "blue" ]]; then previous="green"; else previous="blue"; fi
echo "Rolling back from $active to $previous"
./scripts/switch.sh "$previous"
