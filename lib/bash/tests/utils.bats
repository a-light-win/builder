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

@test "should-skip-arch will fail if PKG_ARCHS is not set" {
  export PKG_ARCHS=""
  run should-skip-arch "x86_64"
  assert_failure
}

@test "should-skip-arch will fail if the arch is in PKG_ARCHS" {
  export PKG_ARCHS="x86_64"
  run should-skip-arch "x86_64"
  assert_failure
}

@test "should-skip-arch will pass if the arch is not in PKG_ARCHS" {
  export PKG_ARCHS="x86_64"
  run should-skip-arch "aarch64"
  assert_success
  assert_line "Skipping arch aarch64."
}

@test "load-array-from-env will load an array from the environment" {
  export ENV_ARRAY_0="a b"
  export ENV_ARRAY_1="b=d"
  export ENV_ARRAY_2="e"
  env_prefix="ENV_ARRAY_"
  expected_array=("a b" "b=d" "e")

  load-array-from-env env_array "$env_prefix"
  assert_equal "${env_array[0]}" "${expected_array[0]}"
  assert_equal "${env_array[1]}" "${expected_array[1]}"
  assert_equal "${env_array[2]}" "${expected_array[2]}"
}

@test "load-builder-env will load variables from builder-env" {
  work_dir="$DIR/dist/load-builder-env"
  mkdir -p "$work_dir"
  pushd "$work_dir" >/dev/null

  echo "PKG_NAME=foo" >builder-env
  load-builder-env
  assert_equal "$PKG_NAME" "foo"

  env | grep -q "PKG_NAME=foo"
  assert [ "$?" -eq 0 ]

  popd >/dev/null
  rm -rf "$work_dir"
}

@test "setup-qemu-user-static will install qemu-user-static if apt-get exists" {
  which() {
    if [ "$1" == "apt-get" ]; then
      return 0
    fi
    return 1
  }
  sudo() {
    "$@"
  }
  apt-get() {
    echo "apt-get"
    for arg in "$@"; do
      echo "$arg"
    done
  }
  systemctl() {
    echo "systemctl"
    for arg in "$@"; do
      echo "$arg"
    done
  }
  export -f apt-get
  run setup-qemu-user-static

  assert_success
  assert_line --index 0 "apt-get"
  assert_line --index 1 "install"
  assert_line --index 2 "-y"
  assert_line --index 3 "qemu-user-static"

  assert_line --index 4 "systemctl"
  assert_line --index 5 "start"
  assert_line --index 6 "systemd-binfmt"
}
