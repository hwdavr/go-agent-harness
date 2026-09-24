#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
COMPOSE="${COMPOSE:-docker compose}"

args=("$@")
file_index=-1
for index in "${!args[@]}"; do
  if [ "${args[$index]}" = "-f" ]; then
    file_index="$index"
    break
  fi
done

if [ "$file_index" -ge 0 ]; then
  file_index_next=$((file_index + 1))
  [ "$file_index_next" -lt "${#args[@]}" ] || { echo "psql test client: -f requires a file" >&2; exit 2; }
  sql_file="${args[$file_index_next]}"
  [ -f "$sql_file" ] || { echo "psql test client: migration file not found: $sql_file" >&2; exit 2; }

  psql_args=()
  for index in "${!args[@]}"; do
    if [ "$index" -eq "$file_index" ] || [ "$index" -eq "$file_index_next" ]; then
      continue
    fi
    psql_args+=("${args[$index]}")
  done

  # The PostgreSQL client runs in the disposable container, so stream host
  # migration files over stdin instead of passing an inaccessible host path.
  $COMPOSE -f "$PROJECT_ROOT/build/docker-compose.test.yml" exec -T db-test psql "${psql_args[@]}" -f - < "$sql_file"
else
  $COMPOSE -f "$PROJECT_ROOT/build/docker-compose.test.yml" exec -T db-test psql "${args[@]}"
fi
