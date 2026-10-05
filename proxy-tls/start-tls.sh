#!/usr/bin/env bash
# start-tls.sh - run the HTTPS front door on https://localhost:8443
set -euo pipefail
cd "$(dirname "$0")"
[[ -f certs/local.crt ]] || ./make-cert.sh
docker rm -f tls-proxy >/dev/null 2>&1 || true
docker run -d --name tls-proxy --network devops-net \
  -p 8443:443 -p 8081:80 \
  -v "$(pwd)/tls.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$(pwd)/certs:/etc/nginx/certs:ro" \
  nginx:1.27-alpine
echo "Open https://localhost:8443 (accept the browser warning - the certificate is self-signed)"
