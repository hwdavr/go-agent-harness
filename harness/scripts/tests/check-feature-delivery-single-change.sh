#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHECKER="$HARNESS_ROOT/scripts/check-stage-artifacts.sh"
FIXTURE_ROOT="$SCRIPT_DIR/fixtures/stage-artifacts"
INVALID_WORKSPACE="docs/product/2026-09-24-sliced"
VALID_WORKSPACE="docs/product/2026-09-24-stage-artifact-fixture"

set +e
(
  cd "$FIXTURE_ROOT"
  "$CHECKER" feature-delivery implementation-plan "$INVALID_WORKSPACE"
)
status=$?
set -e
if [ "$status" -eq 0 ]; then
  echo "FAIL: feature-delivery accepted a sliced implementation plan" >&2
  exit 1
fi

(
  cd "$FIXTURE_ROOT"
  "$CHECKER" feature-delivery implementation-plan "$VALID_WORKSPACE"
)

echo "PASS: feature-delivery rejects slice artifacts and accepts a coherent plan."
