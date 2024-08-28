#!/usr/bin/env bats

setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert'

    DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
    source "$DIR/../podman"
}

@test "podman-run should run a container" {
    podman() {
        for arg in "$@"; do
            echo "$arg"
        done
    }

    run podman-run docker.io/library/debian:12 echo "Hello, World!"
    assert_success

    assert_line --index 0 "run"
    assert_line --index 1 "--rm"
    assert_line --index 2 "--env-host"
    assert_line --index 3 "-v"
    assert_line --index 4 "$(pwd):$(pwd)"
    assert_line --index 5 "-w"
    assert_line --index 6 "$(pwd)"
    assert_line --index 7 "docker.io/library/debian:12"
    assert_line --index 8 "echo"
    assert_line --index 9 "Hello, World!"
}

@test "pre-build-image will skip if no function is defined" {
    run pre-build-image "x86_64"
    assert_success
    assert_output "No builder-pre-build-image found, skip pre-build-image action ..."
}

@test "pre-build-image will run the function" {
    abc-pre-build-image() {
        echo "executed abc-pre-build-image"
    }

    work_dir="${DIR}/dist/pre-build-image/abc"
    mkdir -p "${work_dir}"
    pushd "${work_dir}" >/dev/null

    run pre-build-image "x86_64"
    assert_success
    assert_line --index 0 "Running abc-pre-build-image for x86_64 ..."
    assert_line --index 1 "executed abc-pre-build-image"

    popd >/dev/null
    rm -rf "${work_dir}"
}

@test "build-arch should return asis if no module function is defined" {
    run build-arch "x86_64"
    assert_success
    assert_output "x86_64"
}

@test "build-arch should run the output of module function" {
    abc-build-arch() {
        echo "amd64"
    }

    work_dir="${DIR}/dist/build-arch/abc"
    mkdir -p "${work_dir}"
    pushd "${work_dir}" >/dev/null

    run build-arch "x86_64"
    assert_success
    assert_output "amd64"

    popd >/dev/null
    rm -rf "${work_dir}"
}
