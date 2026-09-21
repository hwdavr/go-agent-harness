#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${HARNESS_PROJECT_ROOT:-$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
PRODUCT_FILE="${1:-$PROJECT_ROOT/docs/product/product.md}"
cd "$PROJECT_ROOT"

start='<!-- HARNESS_TRACKER_START -->'
end='<!-- HARNESS_TRACKER_END -->'
[ -f "$PRODUCT_FILE" ] || { echo "FAIL: $PRODUCT_FILE does not exist" >&2; exit 1; }
[ "$(grep -cF "$start" "$PRODUCT_FILE")" -eq 1 ] || { echo "FAIL: tracker start marker missing or duplicated" >&2; exit 1; }
[ "$(grep -cF "$end" "$PRODUCT_FILE")" -eq 1 ] || { echo "FAIL: tracker end marker missing or duplicated" >&2; exit 1; }

header=$(awk -v s="$start" -v e="$end" '$0 == s {on=1; next} $0 == e {exit} on && /^\| ID \|/ {print; exit}' "$PRODUCT_FILE")
[ "$header" = '| ID | Feature | Workspace | Status | Updated | Notes |' ] || { echo "FAIL: invalid tracker header" >&2; exit 1; }

rows=0
in_progress=0
while IFS='|' read -r _ raw_id raw_feature raw_workspace raw_status raw_updated raw_notes _; do
  id=$(printf '%s' "$raw_id" | sed 's/^ *//;s/ *$//')
  [ -z "$id" ] && continue
  rows=$((rows + 1))
  status=$(printf '%s' "$raw_status" | sed 's/^ *//;s/ *$//')
  updated=$(printf '%s' "$raw_updated" | sed 's/^ *//;s/ *$//')
  workspace=$(printf '%s' "$raw_workspace" | sed -n 's/^ *\[\(docs\/[^]]*\)\](.*) *$/\1/p')
  printf '%s' "$id" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || { echo "FAIL: invalid tracker id $id" >&2; exit 1; }
  printf '%s' "$updated" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' || { echo "FAIL: invalid date for $id" >&2; exit 1; }
  [ -d "$workspace" ] || { echo "FAIL: missing workspace $workspace" >&2; exit 1; }
  case "$status" in
    Planning|"Awaiting implementation approval"|"In Progress"|"To be reviewed"|"To be fixed"|Blocked|Complete) ;;
    *) echo "FAIL: unsupported status '$status' for $id" >&2; exit 1 ;;
  esac
  [ "$status" = "In Progress" ] && in_progress=$((in_progress + 1))
  if [ "$status" = "Complete" ] || [ "$status" = "To be reviewed" ] || [ "$status" = "To be fixed" ]; then
    list="$workspace/feature_list.json"
    [ -f "$list" ] || { echo "FAIL: $status row $id needs $list" >&2; exit 1; }
    if grep -E '"status"[[:space:]]*:' "$list" | grep -Ev '"status"[[:space:]]*:[[:space:]]*"passing"' >/dev/null; then
      echo "FAIL: non-passing slice in $list" >&2
      exit 1
    fi
  fi
done < <(awk -v s="$start" -v e="$end" '$0 == s {on=1; next} $0 == e {exit} on && /^\|/ && $0 !~ /^\| ID \|/ && $0 !~ /^\|---/ {print}' "$PRODUCT_FILE")

[ "$rows" -gt 0 ] || { echo "FAIL: tracker has no rows" >&2; exit 1; }
[ "$in_progress" -le 1 ] || { echo "FAIL: tracker has more than one In Progress row" >&2; exit 1; }
echo "PASS: feature lifecycle tracker valid ($rows feature(s))."
