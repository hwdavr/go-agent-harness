#!/usr/bin/env bash
set -euo pipefail

workflow="${1:-}"
stage="${2:-}"
docs_dir="${3:-}"
[ -n "$workflow" ] && [ -n "$stage" ] && [ -n "$docs_dir" ] || { echo "Usage: $0 <workflow> <stage> <docs/product/YYYY-MM-DD-feature>" >&2; exit 2; }
docs_dir="${docs_dir%/}"
printf '%s' "$docs_dir" | grep -Eq '^docs/product/[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*$' || {
  echo "FAIL: artifact directory must use docs/product/YYYY-MM-DD-feature" >&2
  exit 1
}
[ -d "$docs_dir" ] || { echo "FAIL: missing artifact directory $docs_dir" >&2; exit 1; }

latest() { find "$docs_dir" -maxdepth 1 -type f -name "$1" -print | sort | tail -n 1; }

case "$workflow/$stage" in
  feature-delivery/implementation-plan)
    plan=$(latest 'implementation_plan_v*.md')
    tests=$(latest 'test_plan_v*.md')
    summary=$(latest 'summary_v*.md')
    [ -n "$plan" ] && [ -n "$tests" ] && [ -n "$summary" ] || { echo "FAIL: implementation plan, test plan, and summary are required" >&2; exit 1; }
    if grep -Eq '^## (Vertical )?[Ss]lices$' "$plan"; then
      echo "FAIL: feature-delivery plans must describe one coherent feature; use harness-planning for slices" >&2
      exit 1
    fi
    [ ! -f "$docs_dir/feature_list.json" ] || { echo "FAIL: feature-delivery must not create feature_list.json; use harness-planning for slices" >&2; exit 1; }
    ;;
  bug-fixing/implementation-plan)
    plan=$(latest 'implementation_plan_v*.md')
    tests=$(latest 'test_plan_v*.md')
    summary=$(latest 'summary_v*.md')
    [ -n "$plan" ] && [ -n "$tests" ] && [ -n "$summary" ] || { echo "FAIL: implementation plan, test plan, and summary are required" >&2; exit 1; }
    ;;
  harness-planning/implementation-plan)
    spec=$(latest 'spec_v*.md')
    plan=$(latest 'implementation_plan_v*.md')
    tests=$(latest 'test_plan_v*.md')
    [ -n "$spec" ] && [ -n "$plan" ] && [ -n "$tests" ] || { echo "FAIL: spec, implementation plan, and test plan are required" >&2; exit 1; }
    ;;
  bug-fixing/bug-reproduction)
    plan=$(latest 'implementation_plan_v*.md')
    summary=$(latest 'summary_v*.md')
    [ -n "$plan" ] && [ -n "$summary" ] || { echo "FAIL: implementation plan and summary are required" >&2; exit 1; }
    grep -q '^## Reproduction' "$plan" || { echo "FAIL: reproduction section is missing" >&2; exit 1; }
    grep -Eqi 'RED|FAILED' "$plan" || { echo "FAIL: reproduction evidence must be RED/FAILED" >&2; exit 1; }
    ;;
  *) echo "FAIL: unsupported workflow/stage $workflow/$stage" >&2; exit 2 ;;
esac
echo "PASS: $workflow/$stage artifacts are present."
