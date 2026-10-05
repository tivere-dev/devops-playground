#!/usr/bin/env bash
# vault-demo.sh - run HashiCorp Vault in DEV mode and store/read a secret.
# Dev mode keeps everything in memory with a fixed token: for learning only, never production.
set -euo pipefail

docker rm -f vault >/dev/null 2>&1 || true
docker run -d --name vault --cap-add=IPC_LOCK -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=root hashicorp/vault:1.17
sleep 3

# Helper: run the vault CLI inside the container, already pointed at the server and logged in
v() { docker exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=root vault vault "$@"; }

v status
v kv put secret/devops-app db_password='S3cr3t!' api_key='abc123'
echo "--- read the whole secret:"
v kv get secret/devops-app
echo "--- read one field (what a script or app would do):"
v kv get -field=db_password secret/devops-app
echo
echo "--- the same through the HTTP API with curl (how apps talk to Vault):"
curl -s -H "X-Vault-Token: root" http://localhost:8200/v1/secret/data/devops-app
echo
echo "UI: http://localhost:8200  (token: root)"
