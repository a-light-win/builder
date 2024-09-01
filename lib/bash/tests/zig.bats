#!/usr/bin/env bats

setup() {
  bats_load_library 'bats-support'
  bats_load_library 'bats-assert'

  DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
  source "$DIR/../functions"
}

@test "podman-zig" {
  podman-run() {
    for arg in "$@"; do
      echo "$arg"
    done
  }

  run podman-zig "build"
  assert_success
  assert_line --index 0 "-v"
  assert_line --index 1 "${HOME}/.cache/zig:${HOME}/.cache/zig"
  assert_line --index 2 "${ZIG_IMAGE_FULL}"
  assert_line --index 3 "zig"
  assert_line --index 4 "build"
}

@test "zig-build should skip if arch is not specified" {
  export PKG_ARCHS="x86_64"

  run zig-build "aarch64"
  assert_success
  assert_line "Skipping arch aarch64."
  refute_line "Building project with zig for aarch64 ..."
}

@test "zig-build should build if the arch is specified" {
  export PKG_ARCHS="x86_64"
  podman-zig() {
    for arg in "$@"; do
      echo "$arg"
    done
  }

  run zig-build "x86_64"
  assert_success
  assert_line --index 0 "Building project with zig for x86_64 ..."
  assert_line --index 1 "build"
  assert_line --index 2 "--release=safe"
  assert_line --index 3 "-Dtarget=x86_64-linux-musl"

}

@test "zig-clean" {
  rm() {
    echo "rm $@"
  }
  run zig-clean
  assert_success
  assert_line "rm -rf zig-out/bin/*"
  assert_line "rm -rf zig-out/lib/*"
  assert_line "rm -rf .zig-cache/*"
}

@test "zig-pre-build-image should download the zig binary" {
  curl() {
    echo "curl"
    local arg
    for arg in "$@"; do
      echo "$arg"
    done
  }
  tar() {
    echo "tar"
    local arg
    for arg in "$@"; do
      echo "$arg"
    done
  }
  export ZIG_VERSION=0.13.0
  [ -e zig-linux-x86_64-${ZIG_VERSION} ] && rmdir zig-linux-x86_64-${ZIG_VERSION}

  run zig-pre-build-image x86_64
  assert_success
  assert_line --index 0 "curl"
  assert_line --index 1 "-L"
  assert_line --index 2 "-o"
  assert_line --index 3 "zig-linux-x86_64-${ZIG_VERSION}.tar.xz"
  assert_line --index 4 "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz"

  assert_line --index 5 "tar"
  assert_line --index 6 "xf"
  assert_line --index 7 "zig-linux-x86_64-${ZIG_VERSION}.tar.xz"
}

@test "zig-pre-build-image should not download the zig binary if it exists" {
  curl() {
    echo "curl"
    local arg
    for arg in "$@"; do
      echo "$arg"
    done
  }
  tar() {
    echo "tar"
    local arg
    for arg in "$@"; do
      echo "$arg"
    done
  }

  export ZIG_VERSION=0.13.0
  mkdir -p zig-linux-x86_64-${ZIG_VERSION}

  run zig-pre-build-image x86_64
  assert_success
  assert_line --index 0 "The zig-linux-x86_64-${ZIG_VERSION} already downloaded, skipping"
  refute_line "curl"
  refute_line "tar"

  rmdir zig-linux-x86_64-${ZIG_VERSION}
}
