#!/usr/bin/env bash
set -eu
{
  printf 'version=%s\n' "$(go run ./cmd/gha-fleet provider-release --field derivative_version)"
  printf 'source_commit=%s\n' "$(go run ./cmd/gha-fleet provider-release --field source_commit)"
  printf 'binary_sha256=%s\n' "$(go run ./cmd/gha-fleet provider-release --field binary_sha256)"
} >>"${GITHUB_OUTPUT}"
