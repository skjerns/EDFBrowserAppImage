# EDFBrowser AppImage

Packaging scripts that build [EDFBrowser](https://gitlab.com/Teuniz/EDFbrowser)
(by Teunis van Beelen) as a portable x86_64 **AppImage**, plus a GitHub Actions
workflow that publishes releases automatically.

The EDFBrowser source itself is **not** vendored here — it is cloned fresh from
upstream at build time, so every build tracks the latest release.

## Download

Grab the latest `EDFbrowser-<version>-x86_64.AppImage` from the
[Releases](../../releases) page, then:

```sh
chmod +x EDFbrowser-*-x86_64.AppImage
./EDFbrowser-*-x86_64.AppImage
```

**Requirements:** glibc >= 2.35 (Ubuntu 22.04+, Debian 12+, Fedora 36+, or any
newer distro — Ubuntu-specific nothing) and FUSE. On hosts without FUSE, run it
with `--appimage-extract-and-run`.

## Building locally

Requires rootless **podman** (or docker). Builds inside an Ubuntu 22.04 container
so the result runs on glibc >= 2.35:

```sh
./build-appimage.sh
```

To change the compatibility floor, edit the base image in `build-appimage.sh`
(`ubuntu:22.04` -> glibc 2.35, `ubuntu:20.04` -> 2.31, `ubuntu:24.04` -> 2.38).

## Automated releases (GitHub Actions)

`.github/workflows/build.yml`:

- **Manual run** (`workflow_dispatch`): always builds and publishes a release.
- **Monthly schedule** (1st of each month): builds and releases **only if**
  upstream `PROGRAM_VERSION` is newer than the latest published release.
  A cheap `check` job fetches just `global.h` from GitLab to decide, so months
  with no upstream change cost almost nothing.

Releases are tagged `v<version>` (e.g. `v2.14`). The workflow needs no secrets —
it uses the built-in `GITHUB_TOKEN`.

## Files

| File | Purpose |
|------|---------|
| `ci-build.sh` | The actual build: fresh clone, patches, compile, AppDir, linuxdeploy. Used by CI and the container build. |
| `build-appimage.sh` | Host entrypoint: launches the Ubuntu container. |
| `build-in-container.sh` | Installs deps inside the container, then runs `ci-build.sh`. |
| `.github/workflows/build.yml` | Manual + monthly automated releases. |

## Build notes

Two patches are applied to upstream `edfbrowser.pro` at build time (idempotent):

1. Remove `CONFIG += static` — static linking breaks against the dynamic system Qt5.
2. Add `LIBS += -licui18n -licuuc -licudata` — so the linker resolves the ICU
   symbols Qt5Core pulls in transitively.

The bundled `images/edf.png` is 1024×1024, which linuxdeploy rejects; the script
regenerates it at valid hicolor sizes.
