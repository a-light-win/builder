set unstable := true

# Build images of builders
mod builder 'dockerfiles/Justfile'

# support following environment variables:
# PKG_VERSION: the version is required
# PKG_PLATFORM: default to linux
# PKG_ARCH: default to amd64
# PKG_CONFIG: default to nfpm.yaml
# PKG_TARGET: Where the pakcage save to, default to dist/
# packaging with nfpm (alias of nfpm)
mod pack 'mods/nfpm/Justfile'
# packaging with nfpm
mod nfpm 'mods/nfpm/Justfile'
