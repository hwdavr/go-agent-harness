#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

failed=0
run_check() {
  label="$1"
  shift
  echo ">> $label"
  if "$@"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label" >&2
    failed=1
  fi
}

go_files=$(find . -type f -name '*.go' -not -path './vendor/*' -not -path './.git/*' -not -path './.kilo/*' -print)
run_check "gofmt" test -z "$(gofmt -l $go_files)"

cache_root="${TMPDIR:-/tmp}/notes-app-backend-go-cache"
mkdir -p "$cache_root"
run_check "module root" test -s go.mod
run_check "go vet" env GOCACHE="$cache_root" go vet ./...
run_check "unit tests" env GOCACHE="$cache_root" go test ./...

if rg -n 'internal/db/models|database/sql|stephenafamo/bob|[[:space:]]+`[^`]*SELECT|[[:space:]]+"[^\"]*(SELECT|INSERT|UPDATE|DELETE)' internal/http/handlers >/tmp/notes-app-backend-handler-boundary.txt 2>/dev/null; then
  echo "FAIL: handlers contain persistence imports or SQL; see /tmp/notes-app-backend-handler-boundary.txt" >&2
  failed=1
else
  echo "PASS: handler persistence boundary"
fi

if rg -n 'TODO\(|panic\("not implemented|IMPLEMENTATION REQUIRED' cmd internal -g '*.go' -g '!**/*_test.go' >/tmp/notes-app-backend-stubs.txt 2>/dev/null; then
  echo "FAIL: production stub marker found; see /tmp/notes-app-backend-stubs.txt" >&2
  failed=1
else
  echo "PASS: no production stubs"
fi

exit "$failed"
