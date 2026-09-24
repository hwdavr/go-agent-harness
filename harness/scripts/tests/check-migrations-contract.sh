#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_MIGRATIONS="$SCRIPT_DIR/../check-migrations.sh"
FIXTURES="$SCRIPT_DIR/fixtures/migrations"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

HARNESS_PROJECT_ROOT="$FIXTURES/valid" bash "$CHECK_MIGRATIONS" >"$TEMP_DIR/valid.log"
if HARNESS_PROJECT_ROOT="$FIXTURES/missing-mount" bash "$CHECK_MIGRATIONS" >"$TEMP_DIR/invalid.log" 2>&1; then
  fail "migration contract accepted a Compose profile missing an up migration mount"
fi

echo "PASS: migration contract rejects missing Compose migration mounts."
