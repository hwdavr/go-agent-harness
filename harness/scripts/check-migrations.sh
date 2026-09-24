#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PROJECT_ROOT="${HARNESS_PROJECT_ROOT:-$DEFAULT_PROJECT_ROOT}"
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

for compose in build/docker-compose*.yml; do
  [ -f "$compose" ] || continue
  for up in $ups; do
    migration="$(basename "$up")"
    mount="migrations/$migration:/docker-entrypoint-initdb.d/$migration:ro"
    grep -Fq "$mount" "$compose" || {
      echo "FAIL: $compose does not mount migration $migration for fresh PostgreSQL bootstrap." >&2
      exit 1
    }
  done
done

echo "PASS: $(printf '%s\n' "$ups" | wc -l | tr -d ' ') up migrations have rollback pairs and safe bootstrap wiring."
