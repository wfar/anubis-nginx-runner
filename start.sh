#!/bin/bash
#
# Runs the customized Anubis image on 127.0.0.1:8923.

set -euo pipefail

cd "$(dirname "$0")"
source ./anubis.env

IMAGE="anubis-custom:latest"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Image $IMAGE does not exist. Run ./build.sh first." >&2
  exit 1
fi

if [ -z "$ANUBIS_REDIRECT_DOMAINS" ]; then
  echo "Set ANUBIS_REDIRECT_DOMAINS in anubis.env." >&2
  exit 1
fi

# If no anubis key file is found, a new one is created.
# Best practice is to use existing key so user's pass
# cookie is not invalidated on every start.
if [ ! -s "$ANUBIS_KEY_FILE" ]; then
  mkdir -p "$(dirname "$ANUBIS_KEY_FILE")"
  (umask 077 && openssl rand -hex 32 > "$ANUBIS_KEY_FILE")
fi

docker rm -f anubis >/dev/null 2>&1 || true

ED25519_PRIVATE_KEY_HEX="$(cat "$ANUBIS_KEY_FILE")" \
docker run --detach --name anubis --restart unless-stopped \
  --network host \
  --read-only --cap-drop ALL --security-opt no-new-privileges \
  --memory 256m --log-opt max-size=10m --log-opt max-file=3 \
  --env BIND=127.0.0.1:8923 \
  --env TARGET=http://127.0.0.1:8081 \
  --env "METRICS_BIND=$ANUBIS_METRICS_BIND" \
  --env "REDIRECT_DOMAINS=$ANUBIS_REDIRECT_DOMAINS" \
  --env "COOKIE_DOMAIN=$ANUBIS_COOKIE_DOMAIN" \
  --env ED25519_PRIVATE_KEY_HEX \
  "$IMAGE"
