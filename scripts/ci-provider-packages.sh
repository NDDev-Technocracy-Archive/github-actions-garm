#!/usr/bin/env bash
set -euo pipefail
{
  printf 'directories<<PACKAGES\n'
  ./scripts/provider-package-directories.sh
  printf 'PACKAGES\n'
} >>"${GITHUB_OUTPUT}"
