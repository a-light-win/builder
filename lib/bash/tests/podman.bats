#!/usr/bin/env bats

setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert'

    DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
    source "$DIR/../functions"
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

@test "podman-setup should install podman on debian" {
    sudo() {
        "$@"
    }
    curl() { return 0; }
    gpg() { return 0; }
    tee() { return 0; }
    which() {
        if [ "$1" == "apt-get" ]; then
            return 0
        fi
        return 1
    }
    apt-get() {
        for arg in "$@"; do
            echo "$arg"
        done
    }
    rm() { for arg in "$@"; do echo "$arg"; done; }

    run podman-setup
    assert_success

    assert_line --index 0 "Install third-party repository for podman ..."

    assert_line --index 1 "Try to remove the golang-github-containers-common ..."

    assert_line --index 2 "remove"
    assert_line --index 3 "-y"
    assert_line --index 4 "golang-github-containers-common"

    assert_line --index 5 "autoremove"
    assert_line --index 6 "-y"

    assert_line --index 7 "autoclean"
    assert_line --index 8 "-y"

    assert_line --index 9 "Install the third-party podman ..."
    assert_line --index 10 "update"

    assert_line --index 11 "install"
    assert_line --index 12 "-y"
    assert_line --index 13 "podman"
}

@test "podman-setup should install podman on archlinux" {
    sudo() {
        "$@"
    }
    which() {
        if [ "$1" == "pacman" ]; then
            return 0
        fi
        return 1
    }
    pacman() {
        for arg in "$@"; do
            echo "$arg"
        done
    }
    run podman-setup
    assert_success
    assert_line --index 0 "-Sy"
    assert_line --index 1 "podman"
}

@test "podman-setup should failed if os is not supported" {
    which() {
        return 1
    }

    run podman-setup
    assert_failure
    assert_line --index 0 "Error: unsupported os family"
}

@test "podman-manifest should return immediately if the manifest exists" {
    podman() {
        if [ "$1" == "manifest" ] && [ "$2" == "exists" ]; then
            return 0
        fi
        echo "podman"
        local arg
        for arg in "$@"; do
            echo "$arg"
        done
    }
    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-4"
    run podman-manifest
    assert_success
    assert_output "Manifest ghcr.io/a-light-win/builder/debian:12.6-4 already exists, skipping"
}

@test "podman-manifest should create the manifest" {
    podman() {
        if [ "$1" == "manifest" ] && [ "$2" == "exists" ]; then
            return 1
        fi
        echo "podman"
        local arg
        for arg in "$@"; do
            echo "$arg"
        done
    }
    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-4"
    run podman-manifest
    assert_success

    assert_line --index 0 "Creating manifest ghcr.io/a-light-win/builder/debian:12.6-4"
    assert_line --index 1 "podman"
    assert_line --index 2 "manifest"
    assert_line --index 3 "create"
    assert_line --index 4 "--annotation"
    assert_line --index 5 --partial "org.opencontainers.image.created="
    assert_line --index 6 "ghcr.io/a-light-win/builder/debian:12.6-4"
}

@test "podman-parse-annocations should failed if the label is invalid" {
    export PKG_LABEL_1="invalid-key-value-paire"
    run podman-parse-annotations annotations
    assert_failure
    assert_output "Invalid label: invalid-key-value-paire"
}

@test "podman-manifest-clean should clean the manifest" {
    export PKG_IMAGE="ghcr.io/a-light-win/builder/podman-manifest-clean"
    export PKG_VERSION="1"
    podman manifest create "$PKG_IMAGE:$PKG_VERSION"

    run podman-manifest-clean
    assert_success

    run podman-manifest-clean
    assert_success
}

@test "_validate-podman-manifest-args should failed if PKG_IMAGE is not defined" {
    run _validate-podman-manifest-args
    assert_failure
    assert_output "Error: PKG_IMAGE is not set"
}

@test "_validate-podman-manifest-args should failed if PKG_VERSION is not defined" {
    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    run _validate-podman-manifest-args
    assert_failure
    assert_output "Error: PKG_VERSION is not set"
}

@test "_validate-podman-manifest-args should success" {
    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-4"
    run _validate-podman-manifest-args
    assert_success
}

@test "podman-build should skip if arch is not in PKG_ARCHS" {
    export PKG_ARCHS="x86_64"
    run podman-build "arm64"
    assert_success
    assert_output "Skipping arch arm64."
}

@test "podman-build should return failed if PKG_IMAGE is not defined" {
    run podman-build
    assert_failure
    assert_output "Error: PKG_IMAGE is not set"
}

@test "podman-build should build an image" {
    podman() {
        for arg in "$@"; do
            echo "$arg"
        done
    }

    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-4"
    run podman-build x86_64
    assert_success
    assert_line --index 0 "Building ghcr.io/a-light-win/builder/debian:12.6-4 for x86_64 with build args: "
    assert_line --index 1 "build"
    assert_line --index 2 "--platform"
    assert_line --index 3 "linux/x86_64"
    assert_line --index 4 "--manifest=ghcr.io/a-light-win/builder/debian:12.6-4"
    assert_line --index 5 "--annotation"
    assert_line --index 6 --partial "org.opencontainers.image.created="
    assert_line --index 7 "."
}

@test "podman-build should build an image with build args" {
    podman() {
        for arg in "$@"; do
            echo "$arg"
        done
    }

    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-4"
    export PKG_BUILD_ARG_PROXY="HTTP_PROXY=http://proxy.example.com:80"
    run podman-build x86_64
    assert_success
    assert_line --index 0 "Building ghcr.io/a-light-win/builder/debian:12.6-4 for x86_64 with build args: HTTP_PROXY=http://proxy.example.com:80"
    assert_line --index 1 "build"
    assert_line --index 2 "--platform"
    assert_line --index 3 "linux/x86_64"
    assert_line --index 4 "--manifest=ghcr.io/a-light-win/builder/debian:12.6-4"
    assert_line --index 5 "--annotation"
    assert_line --index 6 --partial "org.opencontainers.image.created="
    assert_line --index 7 "--build-arg"
    assert_line --index 8 "HTTP_PROXY=http://proxy.example.com:80"
    assert_line --index 9 "."
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

@test "podman-tag-and-push should push the image" {
    podman() {
        for arg in "$@"; do
            echo "$arg"
        done
    }
    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-4"
    run podman-tag-and-push
    assert_success

    assert_line --index 0 "manifest"
    assert_line --index 1 "inspect"
    assert_line --index 2 "ghcr.io/a-light-win/builder/debian:12.6-4"

    # first push
    assert_line --index 3 "manifest"
    assert_line --index 4 "push"
    assert_line --index 5 "ghcr.io/a-light-win/builder/debian:12.6-4"

    # tag and push major version
    assert_line --index 6 "tag"
    assert_line --index 7 "ghcr.io/a-light-win/builder/debian:12.6-4"
    assert_line --index 8 "ghcr.io/a-light-win/builder/debian:12"
    assert_line --index 9 "manifest"
    assert_line --index 10 "push"
    assert_line --index 11 "ghcr.io/a-light-win/builder/debian:12"

    # tag and push minor version
    assert_line --index 12 "tag"
    assert_line --index 13 "ghcr.io/a-light-win/builder/debian:12.6-4"
    assert_line --index 14 "ghcr.io/a-light-win/builder/debian:12.6"
    assert_line --index 15 "manifest"
    assert_line --index 16 "push"
    assert_line --index 17 "ghcr.io/a-light-win/builder/debian:12.6"
}

@test "podman-tag-and-push should push the image for develop version" {
    podman() {
        for arg in "$@"; do
            echo "$arg"
        done
    }
    export PKG_IMAGE="ghcr.io/a-light-win/builder/debian"
    export PKG_VERSION="12.6-rc.1"
    run podman-tag-and-push
    assert_success

    assert_line --index 0 "manifest"
    assert_line --index 1 "inspect"
    assert_line --index 2 "ghcr.io/a-light-win/builder/debian:12.6-rc.1"

    assert_line --index 3 "manifest"
    assert_line --index 4 "push"
    assert_line --index 5 "ghcr.io/a-light-win/builder/debian:12.6-rc.1"
}
