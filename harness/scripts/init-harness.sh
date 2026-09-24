#!/usr/bin/env bash
set -euo pipefail

HARNESS_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(cd "$HARNESS_ROOT/.." && pwd)"
cd "$PROJECT_ROOT"

ensure_link() {
  target="$1"
  link="$2"
  if [ -L "$link" ]; then
    echo "OK: $link is linked"
  elif [ -e "$link" ]; then
    echo "FAIL: $link exists but is not the required symlink" >&2
    return 1
  else
    if ! ln -s "$target" "$link"; then
      echo "FAIL: could not create $link" >&2
      return 1
    fi
    echo "CREATED: $link -> $target"
  fi
}

if ! ensure_link ".harness/.agents" ".agents"; then
  echo "WARN: root .agents symlink could not be created; use .harness/.agents directly." >&2
fi
ensure_link ".harness/harness" "harness"
if [ ! -e AGENTS.md ]; then
  ln -s ".harness/AGENTS.md" AGENTS.md
  echo "CREATED: AGENTS.md -> .harness/AGENTS.md"
elif [ -L AGENTS.md ]; then
  echo "OK: AGENTS.md is linked"
else
  echo "OK: project-specific AGENTS.md exists (kept)"
fi

mkdir -p docs/product docs/changes docs/knowledge
echo "INFO: create feature artifacts in docs/product/YYYY-MM-DD-feature/"
bash harness/scripts/check-feature-lifecycle.sh
bash harness/scripts/check-full-source-rules.sh
echo "Harness initialization complete."
