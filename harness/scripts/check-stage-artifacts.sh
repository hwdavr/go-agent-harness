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
  feature-delivery/requirement-analysis|bug-fixing/requirement-analysis|api-contract-update/requirement-analysis)
    spec=$(latest 'spec_v*.md')
    summary=$(latest 'summary_v*.md')
    [ -n "$spec" ] && [ -n "$summary" ] || { echo "FAIL: spec and summary are required" >&2; exit 1; }
    grep -q '^## Rule Applicability' "$spec" || { echo "FAIL: $spec lacks Rule Applicability" >&2; exit 1; }
    for id in ARCH API DB MIG TEST SEC OBS PERF DEP DOC; do
      grep -Eq "^[[:space:]]*\|[[:space:]]*$id[[:space:]]*\|" "$spec" || { echo "FAIL: $spec lacks $id row" >&2; exit 1; }
    done
    ;;
  feature-delivery/implementation-plan|api-contract-update/implementation-plan)
    spec=$(latest 'spec_v*.md')
    plan=$(latest 'implementation_plan_v*.md')
    tests=$(latest 'test_plan_v*.md')
    [ -n "$spec" ] && [ -n "$plan" ] && [ -n "$tests" ] || { echo "FAIL: spec, implementation plan, and test plan are required" >&2; exit 1; }
    base=$(basename "$spec")
    grep -Fq "$base#rule-applicability" "$plan" || { echo "FAIL: plan lacks canonical spec reference" >&2; exit 1; }
    grep -Fq "$base#rule-applicability" "$tests" || { echo "FAIL: test plan lacks canonical spec reference" >&2; exit 1; }
    ;;
  bug-fixing/bug-reproduction)
    spec=$(latest 'spec_v*.md')
    summary=$(latest 'summary_v*.md')
    [ -n "$spec" ] && [ -n "$summary" ] || { echo "FAIL: spec and summary are required" >&2; exit 1; }
    grep -q '^## Reproduction Test' "$spec" || { echo "FAIL: reproduction section is missing" >&2; exit 1; }
    grep -Eqi 'RED|FAILED' "$spec" || { echo "FAIL: reproduction evidence must be RED/FAILED" >&2; exit 1; }
    ;;
  *) echo "FAIL: unsupported workflow/stage $workflow/$stage" >&2; exit 2 ;;
esac
echo "PASS: $workflow/$stage artifacts are present."
