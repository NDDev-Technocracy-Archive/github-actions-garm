#!/usr/bin/env bash
set -euo pipefail
git merge-base --is-ancestor "${SOURCE_COMMIT}" "${HEAD_COMMIT}"
drift=false
while IFS= read -r changed; do
  case "${changed}" in
    *_test.go) continue ;;
    go.mod|go.sum)
      printf 'provider release source drift: %s\n' "${changed}" >&2
      drift=true
      continue
      ;;
  esac
  for directory in ${PROVIDER_PACKAGE_DIRECTORIES}; do
    case "${changed}" in
      "${directory}"/*.go)
        printf 'provider release source drift: %s\n' "${changed}" >&2
        drift=true
        ;;
    esac
  done
done < <(git diff --name-only --diff-filter=ACMRT "${SOURCE_COMMIT}" "${HEAD_COMMIT}")
[[ "${drift}" == false ]]
