#!/usr/bin/env bash
#
# Build the EDFBrowser AppImage from a fresh upstream clone.
#
# Assumes the build dependencies are already installed:
#   build-essential g++ make git wget file imagemagick
#   qtbase5-dev qtbase5-dev-tools libgl-dev libicu-dev
#
# Used by the GitHub Actions workflow and by build-in-container.sh.
# The finished AppImage is left in this directory.
#
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$PWD"

# --- AppImage tooling (downloaded once, reused if present) ------------------
mkdir -p tools
fetch() { [ -f "tools/$1" ] || wget -qO "tools/$1" "$2"; chmod +x "tools/$1"; }
fetch linuxdeploy-x86_64.AppImage           https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
fetch linuxdeploy-plugin-qt-x86_64.AppImage https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
fetch appimagetool-x86_64.AppImage          https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage

# --- Fresh EDFBrowser clone -------------------------------------------------
rm -rf build
mkdir build
cd build
git clone --depth 1 https://gitlab.com/Teuniz/EDFbrowser.git
cd EDFbrowser

# Fix 1: static link breaks against the dynamic system Qt5 -> remove it.
sed -i '/^CONFIG += static$/d' edfbrowser.pro
# Fix 2: link ICU explicitly so the linker resolves the symbols Qt5Core pulls
#        in transitively (idempotent).
grep -q 'licui18n' edfbrowser.pro || \
    sed -i '/^QT += network$/a unix:!mac: LIBS += -licui18n -licuuc -licudata' edfbrowser.pro

VERSION="$(grep '#define PROGRAM_VERSION' global.h | grep -oE '[0-9]+\.[0-9]+[A-Za-z0-9.]*' | head -1)"
[ -n "$VERSION" ] || VERSION="unknown"
echo "EDFBrowser version: $VERSION"

qmake
make -j"$(nproc)"

# --- Populate the AppDir ----------------------------------------------------
rm -rf AppDir
make install INSTALL_ROOT="$PWD/AppDir"

# The bundled images/edf.png is 1024x1024, which linuxdeploy rejects.
# Regenerate every deployed copy at a valid hicolor size.
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps
convert images/edf.png -resize 256x256 AppDir/usr/share/icons/hicolor/256x256/apps/edf.png
convert images/edf.png -resize 48x48   AppDir/usr/share/icons/hicolor/48x48/apps/edf.png
convert images/edf.png -resize 48x48   AppDir/usr/share/icons/hicolor/48x48/mimetypes/edf.png
convert images/edf.png -resize 256x256 AppDir/usr/share/icons/edf.png
convert images/edf.png -resize 256x256 AppDir/usr/share/pixmaps/edf.png

# --- Bundle Qt + build the AppImage ----------------------------------------
# APPIMAGE_EXTRACT_AND_RUN lets the tools run without FUSE (CI runners,
# containers) and is harmless on a FUSE-capable host.
export APPIMAGE_EXTRACT_AND_RUN=1
export QMAKE=/usr/bin/qmake
export ARCH=x86_64
export VERSION
export PATH="$ROOT/tools:$PATH"

"$ROOT/tools/linuxdeploy-x86_64.AppImage" \
    --appdir AppDir \
    --plugin qt \
    --desktop-file AppDir/usr/share/applications/edfbrowser.desktop \
    --icon-file AppDir/usr/share/icons/hicolor/256x256/apps/edf.png \
    --output appimage

mv -f EDFbrowser-*-x86_64.AppImage "$ROOT/"
echo "=== Built: $ROOT/$(cd "$ROOT" && ls EDFbrowser-*-x86_64.AppImage | head -1) ==="
ls -la "$ROOT"/EDFbrowser-*-x86_64.AppImage
