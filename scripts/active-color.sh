#!/usr/bin/env bash
# active-color.sh - prints which slot (blue or green) the proxy currently sends traffic to.
# In canary mode the FIRST server line (the main, old version) counts as the active slot.
set -euo pipefail
active=$(docker exec proxy cat /etc/nginx/active.conf | grep -oE 'app-(blue|green)' | head -1 | cut -d- -f2)
echo "${active:-unknown}"
