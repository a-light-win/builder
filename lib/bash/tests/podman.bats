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
    assert_line --index 2 "--env-hosts"
    assert_line --index 3 "-v"
    assert_line --index 4 "$(pwd):$(pwd)"
    assert_line --index 5 "-w"
    assert_line --index 6 "$(pwd)"
    assert_line --index 7 "docker.io/library/debian:12"
    assert_line --index 8 "echo"
    assert_line --index 9 "Hello, World!"
}
