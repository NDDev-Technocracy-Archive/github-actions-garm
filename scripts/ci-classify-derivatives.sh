#!/usr/bin/env bash
set -euo pipefail
if [[ "${EVENT_NAME}" == workflow_dispatch ]]; then
  printf 'garm=true\nprovider=true\n' >>"${GITHUB_OUTPUT}"
  exit 0
fi
base="${BASE_SHA:-${BEFORE_SHA:-}}"
if [[ ! "${base}" =~ ^[0-9a-f]{40}$ || "${base}" == 0000000000000000000000000000000000000000 ]]; then
  printf 'garm=true\nprovider=true\n' >>"${GITHUB_OUTPUT}"
  exit 0
fi
git cat-file -e "${base}^{commit}"
git cat-file -e "${HEAD_SHA}^{commit}"
./scripts/validate-image-alias-advance.sh "${base}" "${HEAD_SHA}"
garm=false
provider=false
while IFS= read -r changed; do
  case "${changed}" in
    config/garm-derivative.yaml|scripts/build-garm-nddev.sh|third_party/garm/*|internal/garmderivative/*|go.mod|go.sum)
      garm=true
      ;;
  esac
  case "${changed}" in
    config/provider-derivative.yaml|go.mod|go.sum)
      provider=true
      ;;
    *)
      # Every directory the provider binary actually compiles, read
      # from the build graph rather than from a list maintained by
      # hand. The hand-written list named eight of the eighteen
      # internal packages `go list -deps` reports, so a change to
      # internal/cachebroker or internal/queueintent -- both real
      # provider dependencies -- skipped this job entirely and shipped
      # under a manifest digest that no longer described main.
      for directory in ${PROVIDER_PACKAGE_DIRECTORIES}; do
        case "${changed}" in
          "${directory}"/*.go) provider=true ;;
        esac
      done
      ;;
  esac
done < <(git diff --name-only --diff-filter=ACMRT "${base}" "${HEAD_SHA}")
printf 'garm=%s\nprovider=%s\n' "${garm}" "${provider}" >>"${GITHUB_OUTPUT}"
