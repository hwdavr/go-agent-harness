#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "--validate" ] || [ -z "${2:-}" ]; then
  echo "Usage: $0 --validate <summary-file>" >&2
  exit 2
fi

file="$2"
[ -s "$file" ] || { echo "FAIL: missing summary $file" >&2; exit 1; }
grep -q '^## Observability & Execution Metrics' "$file" || { echo "FAIL: metrics section missing" >&2; exit 1; }
grep -q '```json:metrics' "$file" || { echo "FAIL: json:metrics block missing" >&2; exit 1; }
for field in agent started_at completed_at commands tests failures_before_pass files_changed; do
  grep -q "\"$field\"" "$file" || { echo "FAIL: metrics field missing: $field" >&2; exit 1; }
done
echo "PASS: metrics block is present in $file."
