#!/usr/bin/env bats

setup() {
  bats_load_library 'bats-support'
  bats_load_library 'bats-assert'

  DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
  source "$DIR/../utils"
}

@test "go-arch should return amd64 if input is x86_64" {
  run go-arch x86_64
  assert_success
  assert_output "amd64"
}

@test "go-arch should return arm64 if input is aarch64" {
  run go-arch aarch64
  assert_success
  assert_output "arm64"
}

@test "go-arch should return amd64 if input is amd64" {
  run go-arch amd64
  assert_success
  assert_output "amd64"
}
