#!/usr/bin/env bats

setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert'

    DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
    source "$DIR/../nfpm"
}

@test "nfpm-pre-pack will fail if PKG_VERSION is not set" {
    export PKG_VERSION=""
    run nfpm-pre-pack
    assert_failure
    assert_line "version is required, please provide it with env PKG_VERSION"
}

@test "nfpm-pre-pack will create the output directory" {
    export PKG_VERSION="1.0.0"
    export PKG_TARGET="${DIR}/dist-pre-pack"

    run nfpm-pre-pack
    assert_success
    assert [ -d "${PKG_TARGET}" ]

    rmdir "${PKG_TARGET}"
}

@test "nfpm-pack will skip the arch" {
    export PKG_ARCHS="x86_64"
    run nfpm-pack "deb" "aarch64"
    assert_success
    assert_line "Skipping arch aarch64."
}

@test "fpm-pack will skip the packager" {
    export PKG_PACKAGERS="deb"
    run nfpm-pack "rpm" "x86_64"
    assert_success
    assert_line "Skipping packager rpm."
}

@test "nfpm-pack will call podman-nfpm" {
    podman-nfpm() {
        for arg in "$@"; do
            echo "$arg"
        done
    }
    run nfpm-pack "deb" "x86_64"
    assert_success
    assert_line --index 0 "package"
    assert_line --index 1 "--config"
    assert_line --index 2 "nfpm.yaml"
    assert_line --index 3 "--packager"
    assert_line --index 4 "deb"
    assert_line --index 5 "--target"
    assert_line --index 6 "dist"
}

@test "podman-nfpm" {
    podman-run() {
        for arg in "$@"; do
            echo "$arg"
        done
    }
    run podman-nfpm package
    assert_success
    assert_line --index 0 "${NFPM_IMAGE_FULL}"
    assert_line --index 1 "nfpm"
    assert_line --index 2 "package"

}

@test "nfpm-clean" {
    rm() {
        echo "rm $@"
    }
    run nfpm-clean
    assert_success
    assert_line "rm -f dist/*.deb"
    assert_line "rm -f dist/*.rpm"
    assert_line "rm -f dist/*.tar.zst"
    assert_line "rm -f dist/*.apk"
    assert_line "rm -f dist/*.sha256"
}

@test "nfpm-pkg-files" {
    export PKG_TARGET="${DIR}/dist"
    mkdir -p "${PKG_TARGET}"

    touch "${PKG_TARGET}/a deb pkg.deb"
    touch "${PKG_TARGET}/rpm-pkg.rpm"

    files=()
    nfpm-pkg-files files

    assert_equal "${#files[@]}" 4
    assert_equal "${files[0]}" "${PKG_TARGET}/a deb pkg.deb"
    assert_equal "${files[1]}" "${PKG_TARGET}/a deb pkg.deb.sha256"
    assert_equal "${files[2]}" "${PKG_TARGET}/rpm-pkg.rpm"
    assert_equal "${files[3]}" "${PKG_TARGET}/rpm-pkg.rpm.sha256"

    run nfpm-clean
    assert_success
    assert [ ! -e "${PKG_TARGET}/a deb pkg.deb" ]
    assert [ ! -e "${PKG_TARGET}/a deb pkg.deb.sha256" ]
    assert [ ! -e "${PKG_TARGET}/rpm-pkg.rpm" ]
    assert [ ! -e "${PKG_TARGET}/rpm-pkg.rpm.sha256" ]
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

@test "should-skip-packager will fail if PKG_PACKAGERS is not set" {
    export PKG_PACKAGERS=""
    run should-skip-packager "deb"
    assert_failure
}

@test "should-skip-packager will fail if the packager is in PKG_PACKAGERS" {
    export PKG_PACKAGERS="deb"
    run should-skip-packager "deb"
    assert_failure
}

@test "should-skip-packager will pass if the packager is not in PKG_PACKAGERS" {
    export PKG_PACKAGERS="deb"
    run should-skip-packager "rpm"
    assert_success
    assert_line "Skipping packager rpm."
}
