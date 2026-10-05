#!/usr/bin/env bash
# watch-traffic.sh - ask the site once a second and print which color/version answered.
# Leave it running in a second terminal while you deploy, switch or roll back. Ctrl+C to stop.
while true; do
  printf '%s  ' "$(date +%H:%M:%S)"
  curl -s --max-time 2 http://localhost:8080/api || printf 'NO ANSWER'
  echo
  sleep 1
done
