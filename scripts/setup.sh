#!/usr/bin/env bash
# setup.sh - first-time start: network, app v1 on BLUE, and the nginx proxy on port 8080
set -euo pipefail
cd "$(dirname "$0")/.."              # run from the project root, wherever you call it from

echo "1/4 Creating the shared Docker network 'devops-net' (if it doesn't exist)"
docker network inspect devops-net >/dev/null 2>&1 || docker network create devops-net

echo "2/4 Building the app image devops-app:v1"
docker build -t devops-app:v1 ./app

echo "3/4 Starting app v1 in the BLUE slot"
docker rm -f app-blue >/dev/null 2>&1 || true
docker run -d --name app-blue --network devops-net \
  -e COLOR=blue -e VERSION=v1 --restart unless-stopped devops-app:v1

echo "4/4 Building and starting the proxy on http://localhost:8080"
docker build -t devops-proxy ./proxy
docker rm -f proxy >/dev/null 2>&1 || true
docker run -d --name proxy --network devops-net -p 8080:80 \
  --restart unless-stopped devops-proxy

echo "Done. Open http://localhost:8080 in your browser (it should be BLUE, v1)."
