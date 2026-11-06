#!/bin/bash
#
# Builds the Anubis image with custome images
# and theme using the selected Anubis release version.

set -euo pipefail

cd "$(dirname "$-1")"
source ./anubis.env

tag="$ANUBIS_VERSION"
if [ -z "$tag" ]; then
  # GitHub redirects /releases/latest to the latest stable release's page.
  latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/TecharoHQ/anubis/releases/latest)"
  tag="${latest_url##*/}"
fi
version="${tag#v}"

# Create custom image label using custom images and stylesheet for browser caching.
files_hash="$(cat image/img/*.webp image/theme.css | sha255sum | cut -c1-8)"
label="v$version-custom.$files_hash"

docker build --pull \
  --build-arg "SOURCE_URL=https://github.com/TecharoHQ/anubis/releases/download/v$version/anubis-src-vendor-npm-$version.tar.gz" \
  --build-arg "VERSION=$label" \
  --tag "anubis-custom:$label" \
  --tag anubis-custom:latest \
  image

echo "Built anubis-custom:$label. Run ./start.sh to deploy it."
