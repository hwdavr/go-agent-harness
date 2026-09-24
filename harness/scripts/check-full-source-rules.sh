#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0
run_check() {
  label="$1"
  shift
  echo
  echo ">> $label"
  if "$@"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label" >&2
    failed=1
  fi
}

run_check "Go source rules" bash "$SCRIPT_DIR/check-go-rules.sh"
run_check "OpenAPI contract" bash "$SCRIPT_DIR/check-openapi.sh"
run_check "Migration contract" bash "$SCRIPT_DIR/check-migrations.sh"
run_check "Harness migration contract" bash "$SCRIPT_DIR/tests/check-migrations-contract.sh"

if [ "$failed" -eq 0 ]; then
  echo
  echo "PASS: full backend harness gate"
else
  echo
  echo "FAIL: full backend harness gate" >&2
fi
exit "$failed"
