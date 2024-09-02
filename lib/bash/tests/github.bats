#!/usr/bin/env bats

setup() {
  bats_load_library 'bats-support'
  bats_load_library 'bats-assert'

  DIR="$(realpath "$(dirname "$BATS_TEST_FILENAME")")"
  source "$DIR/../github"
}

@test "github-release should failed if the PKG_VERSION is not set" {
  run github-release assets_url "OWNER/REPO"
  assert_failure
  assert_output "PKG_VERSION is required"
}

@test "github-release should failed if the GITHUB_TOKEN is not set" {
  export PKG_VERSION="1.0.0"
  run github-release assets_url "OWNER/REPO"
  assert_failure
  assert_output "GITHUB_TOKEN is required"
}

@test "github-release should failed if the repo is not in 'OWNER/REPO' format" {
  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"
  run github-release assets_url "OWNER"
  assert_failure
  assert_output "repo should be in 'OWNER/REPO' format but got 'OWNER'"
}

@test "github-release should not create a new release if the release already exists" {
  gh() {
    echo 'https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets'
  }

  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"
  github-release assets_url "OWNER/REPO"
  assert_equal "$assets_url" "https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets"
}

@test "github-release should create a new release if the release does not exist" {
  gh() {
    grep -q "tags" <<<"$6"
    if [ $? -eq 0 ]; then
      return 1
    fi

    echo 'https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets'
  }

  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"
  run github-release assets_url "OWNER/REPO"
  assert_success
}

@test "github-upload should failed if no file to upload" {
  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"
  run github-upload "OWNER/REPO"
  assert_failure
  assert_output "No file to upload"
}

@test "github-upload should failed if the file not found" {
  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"
  run github-upload "OWNER/REPO" "file-not-exists"
  assert_failure
  assert_output "File not found: file-not-exists"
}

@test "github-upload should retry 3 times on failure" {
  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"

  _retries=0
  github_upload_retry_interval=0
  _github-upload-one-internal() {
    _retries="$((_retries + 1))"
    echo "retry $_retries times"
    return 1
  }

  run github-upload "https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets" "$DIR/github.bats"
  assert_failure
  assert_line "Failed to upload $DIR/github.bats to https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets?name=github.bats"
  assert_line "retry 3 times"
}

@test "github-upload should send to the correct URL" {
  export PKG_VERSION="1.0.0"
  export GITHUB_TOKEN="123456"

  curl() {
    for arg in "$@"; do
      echo "$arg"
    done
  }

  run github-upload "https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets" "$DIR/github.bats" "$DIR/utils.bats"
  assert_success
  assert_line "Uploading $DIR/github.bats to https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets?name=github.bats ..."
  assert_line "Uploading $DIR/utils.bats to https://uploads.github.com/repos/OWNER/REPO/releases/1.0.0/assets?name=utils.bats ..."
}
