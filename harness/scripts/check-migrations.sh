#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

ups=$(find migrations -maxdepth 1 -type f -name '*.up.sql' -print | sort)
[ -n "$ups" ] || { echo "FAIL: no up migrations found" >&2; exit 1; }

for up in $ups; do
  stem="${up%.up.sql}"
  down="${stem}.down.sql"
  [ -f "$down" ] || { echo "FAIL: missing rollback migration for $up" >&2; exit 1; }
done

if grep -R -n -E 'migrations:/docker-entrypoint-initdb.d|\.down\.sql' build/docker-compose*.yml 2>/dev/null; then
  echo "FAIL: Docker bootstrap must mount only explicit up migrations, never a directory or down migration." >&2
  exit 1
fi

echo "PASS: $(printf '%s\n' "$ups" | wc -l | tr -d ' ') up migrations have rollback pairs and safe bootstrap wiring."
