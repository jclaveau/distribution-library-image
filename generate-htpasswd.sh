#!/bin/bash

# Regenerates the htpasswd file from env vars on every container start, so
# credentials live in Railway variables rather than in a persistent volume.
#
# Expected env:
#   REGISTRY_HTPASSWD           — one "user:password" per line (multi-line value)
#   REGISTRY_AUTH_HTPASSWD_PATH — output path (default: /etc/docker/registry/htpasswd)
#
# The registry's own auth still has to be enabled via the usual registry env
# vars, e.g.:
#   REGISTRY_AUTH=htpasswd
#   REGISTRY_AUTH_HTPASSWD_REALM=Registry
#   REGISTRY_AUTH_HTPASSWD_PATH=/etc/docker/registry/htpasswd

set -e

HTPASSWD_PATH="${REGISTRY_AUTH_HTPASSWD_PATH:-/etc/docker/registry/htpasswd}"

if [ -z "$REGISTRY_HTPASSWD" ]; then
  exit 0
fi

mkdir -p "$(dirname "$HTPASSWD_PATH")"
: > "$HTPASSWD_PATH"

while IFS= read -r line; do
  [ -z "$line" ] && continue
  user="${line%%:*}"
  pass="${line#*:}"
  if [ -z "$user" ] || [ "$user" = "$line" ]; then
    echo "generate-htpasswd: invalid entry (expected user:password): $line" >&2
    exit 1
  fi
  htpasswd -Bb "$HTPASSWD_PATH" "$user" "$pass" >/dev/null
done <<< "$REGISTRY_HTPASSWD"
