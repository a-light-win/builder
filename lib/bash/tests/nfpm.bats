#!/usr/bin/env bats

setup() {
    bats_load_library 'bats-support'
    bats_load_library 'bats-assert'

    DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
    source "$DIR/../nfpm"
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
    export NFPM_OUTPUT_DIR="${DIR}/dist"
    export PKG_TARGET="${NFPM_OUTPUT_DIR}"
    mkdir -p "${NFPM_OUTPUT_DIR}"

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
