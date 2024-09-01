#!/usr/bin/env bash

setup() {
  bats_load_library 'bats-support'
  bats_load_library 'bats-assert'

  DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
  source "$DIR/../version"
}

@test "version-is-develop should return true for alpha versions" {
  run version-is-develop "1.2.3-alpha4"
  assert_success

  run version-is-develop "1.2.3-alpha.4"
  assert_success
}

@test "version-is-develop should return true for beta versions" {
  run version-is-develop "1.2.3-beta4"
  assert_success
  run version-is-develop "1.2.3-beta.4"
  assert_success
}

@test "version-is-develop should return true for rc versions" {
  run version-is-develop "1.2.3-rc4"
  assert_success
  run version-is-develop "1.2.3-rc.4"
  assert_success
}

@test "version-is-develop should return false for non-develop versions" {
  run version-is-develop "1.2.3"
  assert_failure
}

@test "version-components should split version components" {
  version-components prefix components "1.2.3-4"
  assert_equal "$prefix" ""
  assert_equal "${components[0]}" "1."
  assert_equal "${components[1]}" "2."
  assert_equal "${components[2]}" "3-"
  assert_equal "${components[3]}" "4"

  version-components prefix components "abc-1.2.3"
  assert_equal "$prefix" "abc-"
  assert_equal "${components[0]}" "1."
  assert_equal "${components[1]}" "2."
  assert_equal "${components[2]}" "3"

  version-components prefix components "v1.2.3"
  assert_equal "$prefix" "v"
  assert_equal "${components[0]}" "1."
  assert_equal "${components[1]}" "2."
  assert_equal "${components[2]}" "3"
}

@test "version-list should list all version components" {
  local versions
  version-list versions "1.2.3-4"
  assert_equal "${#versions[@]}" 4
  assert_equal "${versions[0]}" "1"
  assert_equal "${versions[1]}" "1.2"
  assert_equal "${versions[2]}" "1.2.3"
  assert_equal "${versions[3]}" "1.2.3-4"

  version-list versions "abc-1.2.3"
  assert_equal "${#versions[@]}" 3
  assert_equal "${versions[0]}" "abc-1"
  assert_equal "${versions[1]}" "abc-1.2"
  assert_equal "${versions[2]}" "abc-1.2.3"

  version-list versions "v1.2.3"
  assert_equal "${#versions[@]}" 3
  assert_equal "${versions[0]}" "v1"
  assert_equal "${versions[1]}" "v1.2"
  assert_equal "${versions[2]}" "v1.2.3"
}

@test "version-major should return the major version" {
  run version-major "1.2.3-4"
  assert_success
  assert_output "1"

  run version-major "abc-1.2.3-4"
  assert_success
  assert_output "1"

  run version-major "v1.2.3-4"
  assert_success
  assert_output "1"
}

@test "version-major should return error for invalid version" {
  run version-major "v"
  assert_failure
  assert_output "Invalid version: v"
}
