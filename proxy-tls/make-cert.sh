#!/usr/bin/env bash
# make-cert.sh - create a self-signed certificate for https://localhost (lab only)
set -euo pipefail
cd "$(dirname "$0")/certs"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout local.key -out local.crt -subj "/CN=localhost"
chmod 600 local.key
echo "Created certs/local.crt (certificate) and certs/local.key (private key)"
