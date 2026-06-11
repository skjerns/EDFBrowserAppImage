# EDFBrowser AppImage

Builds [EDFBrowser](https://gitlab.com/Teuniz/EDFbrowser) (by Teunis van Beelen)
as a portable x86_64 **AppImage**. The source is cloned fresh from upstream at
build time — nothing is vendored here.

## Download

Get the latest AppImage from [Releases](../../releases), then:

```sh
chmod +x EDFbrowser-*-x86_64.AppImage
./EDFbrowser-*-x86_64.AppImage
```

Needs glibc ≥ 2.35 (Ubuntu 22.04+, Debian 12+, Fedora 36+, …) and FUSE — or run
with `--appimage-extract-and-run`.

## Build locally

Requires rootless **podman** (or docker); builds in an Ubuntu 22.04 container:

```sh
./build-appimage.sh
```

## Releases

`.github/workflows/build.yml`: **manual run** always publishes a release;
**monthly schedule** publishes only when upstream's version increased.

## License

[GPL-3.0](LICENSE), same as EDFBrowser.
