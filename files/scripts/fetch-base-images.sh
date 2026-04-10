# modules/fetch-base-images.sh
#!/usr/bin/bash
set -euo pipefail

BASE_DIR="/usr/share/bulwarkos/base-images"
RELEASE_URL="https://github.com/connorethanjay/bulwarkos/releases/download/base-images-v1"

mkdir -p "$BASE_DIR"

echo "Fetching Alpine NoCloud base image..."
curl -L --retry 3 -o "$BASE_DIR/alpine-nocloud.qcow2" \
  "$RELEASE_URL/alpine-nocloud.qcow2"

echo "Fetching Fedora Cloud Base image..."
curl -L --retry 3 -o "$BASE_DIR/fedora-cloud-base.qcow2" \
  "$RELEASE_URL/fedora-cloud-base.qcow2"

echo "Verifying checksums..."
sha256sum -c "$BASE_DIR/SHA256SUMS"
