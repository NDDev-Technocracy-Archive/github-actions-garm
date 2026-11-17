#!/usr/bin/env bash
set -eu
for output in provider-a provider-b; do
  CGO_ENABLED=0 go build -trimpath -buildvcs=false \
    -ldflags "-buildid= -s -w -X main.version=${VERSION} -X main.commit=${SOURCE_COMMIT}" \
    -o "${RUNNER_TEMP}/${output}" ./cmd/garm-provider-incus-nddev
done
cmp "${RUNNER_TEMP}/provider-a" "${RUNNER_TEMP}/provider-b"
actual_sha256="$(sha256sum "${RUNNER_TEMP}/provider-a" | awk '{print $1}')"
printf 'provider source=%s expected=%s actual=%s\n' \
  "${SOURCE_COMMIT}" "${EXPECTED_SHA256}" "${actual_sha256}"
test "${actual_sha256}" = "${EXPECTED_SHA256}"
