set shell := ["bash", "-euo", "pipefail", "-c"]

# Lists the maintained source, native and CI artifact commands.
default:
    @just --list

# Fetches and verifies the declared module graph without accepting lock changes.
setup:
    go mod download
    go mod verify
    git diff --exit-code -- go.mod go.sum

# Runs build-free Go, workflow, shell and source-history checks.
check: check-go check-ci

# Preserves the native build tool's formatting check.
[group('checks')]
check-go:
    make fmt-check

# Checks recipes, workflows, extracted CI shell and the complete Git source history.
[group('checks')]
check-ci:
    just --fmt --check
    actionlint
    zizmor --offline --no-progress .github/workflows/ci.yml .github/workflows/security.yml .github/dependabot.yml
    shellcheck scripts/ci-*.sh
    GIT_NO_LAZY_FETCH=1 gitleaks git --no-banner --redact --log-opts=--all .

# Formats Go source and the project commands.
fix:
    gofmt -w cmd internal third_party
    just --fmt

# Runs all ordinary native, race, release-manifest and nested-module feedback.
test: vet test-unit test-race test-release-manifest

# Runs the existing root and nested-module vet checks on an execution host.
[group('native')]
vet:
    make vet
    go vet -C internal/incusplacement/starlarkexec ./...

# Runs the unchanged ordinary Go suite and background-feedback fixture.
[group('native')]
test-unit:
    make test
    python3 -m unittest discover -s tests -p test_ci_feedback.py -v

# Preserves the existing Go race detector suite.
[group('native')]
test-race:
    make test-race

# Preserves the build tool's controller-release manifest checks.
[group('native')]
test-release-manifest:
    make test-controller-release-manifest

# Builds all existing Go targets through their native build tool.
build:
    make build

# Runs complete ordinary source/native/build feedback without a live host or provider.
verify: check test build

# Keeps the static/build CI job's actual native and provenance checks.
[group('ci')]
verify-static: check-go vet test-release-manifest build

# Emits the exact compiled provider package directories for CI classification.
[group('ci')]
provider-packages:
    scripts/ci-provider-packages.sh

# Preserves the existing derivative-input and image-alias classifier.
[group('ci')]
classify-derivatives:
    scripts/ci-classify-derivatives.sh

# Builds the existing GARM derivative through its owning manifest/tool.
[group('qualification')]
build-garm-derivative:
    make build-garm-derivative

# Emits the validated existing provider-release identity for the CI source checkout.
[group('ci')]
provider-identity:
    scripts/ci-provider-identity.sh

# Refuses source drift from the provider's accepted release commit.
[group('qualification')]
check-provider-source:
    scripts/ci-provider-drift.sh

# Rebuilds the exact checked-out provider twice and verifies its declared bytes.
[group('qualification')]
[working-directory('provider-source')]
qualify-provider:
    ../scripts/ci-provider-rebuild.sh
