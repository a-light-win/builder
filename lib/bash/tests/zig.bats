#!/usr/bin/env bats

setup() {
  bats_load_library 'bats-support'
  bats_load_library 'bats-assert'

  DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
  source "$DIR/../zig"
}

@test "podman-zig" {
  podman-run() {
    for arg in "$@"; do
      echo "$arg"
    done
  }

  run podman-zig "zig:0.13.0" "build"
  assert_success
  assert_line --index 0 "-v"
  assert_line --index 1 "${HOME}/.cache/zig:${HOME}/.cache/zig"
  assert_line --index 2 "zig:0.13.0"
  assert_line --index 3 "zig"
  assert_line --index 4 "build"
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
