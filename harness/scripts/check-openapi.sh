#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

[ -s openapi.yaml ] || { echo "FAIL: openapi.yaml is missing or empty" >&2; exit 1; }

for path in \
  '/healthz' \
  '/v1/items:' \
  '/v1/items/{itemID}:' \
  '/v1/folders:' \
  '/v1/notes:' \
  '/v1/items/{itemID}/rename:' \
  '/v1/items/{itemID}/move:' \
  '/v1/items/{itemID}/reorder:' \
  '/v1/items/{itemID}/favorite:' \
  '/v1/items/{itemID}/content:' \
  '/v1/notes/{itemID}/content:' \
  '/v1/notes/{itemID}/shares:' \
  '/v1/notes/{itemID}/blocks/{blockID}/comments'; do
  if ! grep -Fq "$path" openapi.yaml; then
    echo "FAIL: router path is missing from OpenAPI: $path" >&2
    exit 1
  fi
done

operation_ids=$(grep -E '^[[:space:]]+operationId:' openapi.yaml | sed 's/.*operationId:[[:space:]]*//' | sort)
if [ -n "$(printf '%s\n' "$operation_ids" | sed '/^$/d' | uniq -d)" ]; then
  echo "FAIL: duplicate OpenAPI operationId" >&2
  exit 1
fi

echo "PASS: OpenAPI contract contains all public router paths and unique operationIds."
