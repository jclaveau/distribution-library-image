#!/bin/bash

# Regenerates the htpasswd file from env vars on every container start, so
# credentials live in Railway variables rather than in a persistent volume.
#
# Expected env:
#   HTPASSWD_USERS  — one "user:password" per line (multi-line value)
#
# Auth is wired declaratively in config-example.yml (auth.htpasswd.path), so
# this script must produce a valid file at /etc/docker/registry/htpasswd or
# the registry will refuse to start.

set -e

HTPASSWD_PATH="/etc/docker/registry/htpasswd"

if [ -z "$HTPASSWD_USERS" ]; then
  echo "generate-htpasswd: HTPASSWD_USERS is not set; refusing to start with auth enabled but no credentials" >&2
  exit 1
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
done <<< "$HTPASSWD_USERS"
