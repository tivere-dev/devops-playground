#!/usr/bin/env bash
docker rm -f web1 web2 ansible-control 2>/dev/null
echo "Removed web1, web2, ansible-control."
