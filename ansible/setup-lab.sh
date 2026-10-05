#!/usr/bin/env bash
# setup-lab.sh - create an SSH key, build the images, start 2 target servers and the control node
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p keys
if [[ ! -f keys/id_ed25519 ]]; then
  ssh-keygen -t ed25519 -N "" -f keys/id_ed25519 -C "ansible-lab"   # -N "" = no passphrase (lab only)
fi
cp keys/id_ed25519.pub images/target/id_ed25519.pub

docker network inspect devops-net >/dev/null 2>&1 || docker network create devops-net
docker build -t ansible-target images/target
docker build -t ansible-control images/control

for n in web1 web2; do
  docker rm -f "$n" >/dev/null 2>&1 || true
  docker run -d --name "$n" --hostname "$n" --network devops-net ansible-target
done

docker rm -f ansible-control >/dev/null 2>&1 || true
docker run -d --name ansible-control --network devops-net \
  -v "$(pwd)":/ansible ansible-control sleep infinity

# ssh refuses private keys that others can read, so copy it in with 600 permissions
docker exec ansible-control sh -c 'mkdir -p /root/.ssh && cp /ansible/keys/id_ed25519 /root/.ssh/id_ed25519 && chmod 600 /root/.ssh/id_ed25519'
echo "Lab ready. Next: docker exec -it ansible-control bash"
