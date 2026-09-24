#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHECKER="$HARNESS_ROOT/scripts/check-stage-artifacts.sh"
FIXTURE_ROOT="$SCRIPT_DIR/fixtures/stage-artifacts"

set +e
(
  cd "$FIXTURE_ROOT"
  "$CHECKER" feature-delivery implementation-plan
)
status=$?
set -e
if [ "$status" -eq 0 ]; then
  echo "FAIL: stage artifact check accepted the former implicit docs/current workspace" >&2
  exit 1
fi

(
  cd "$FIXTURE_ROOT"
  "$CHECKER" feature-delivery implementation-plan docs/product/2026-09-24-stage-artifact-fixture
)

echo "PASS: dated feature workspace is required."
