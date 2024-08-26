PKG_VERSION=0.1.0
PKG_ARCHS="x86_64 aarch64"
PKG_PACKAGERS="deb rpm archlinux"
PKG_TARGET=dist/

# --release option in zig build,
# should be one of safe, fast and small.
# default to safe
ZIG_RELEASE=safe
