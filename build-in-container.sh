#!/usr/bin/env bash
#
# Installs build dependencies inside an Ubuntu container, then runs ci-build.sh.
# Invoked by build-appimage.sh — do not run directly on the host.
#
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    build-essential g++ make git wget ca-certificates file imagemagick \
    qtbase5-dev qtbase5-dev-tools libgl-dev libicu-dev \
    libfontconfig1 libfreetype6

exec bash "$(dirname "$0")/ci-build.sh"
