#!/usr/bin/env bash
#
# Build the EDFBrowser AppImage inside an Ubuntu 24.04 container (glibc 2.39)
# so the result runs on glibc >= 2.39 systems (Ubuntu 24.04 and newer, and
# most current distros). Run this on the host:
#
#   ./build-appimage.sh
#
# Requires rootless podman (or docker). The project dir is mounted at /work.
#
set -euo pipefail
cd "$(dirname "$0")"

ENGINE=""
if command -v podman >/dev/null 2>&1; then
    ENGINE=podman
elif command -v docker >/dev/null 2>&1; then
    ENGINE=docker
else
    echo "error: need podman or docker installed" >&2
    exit 1
fi

echo "Using container engine: $ENGINE"
"$ENGINE" run --rm \
    -v "$PWD":/work:Z \
    -w /work \
    docker.io/library/ubuntu:22.04 \
    bash /work/build-in-container.sh
