#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
cd "$PROJECT_ROOT"

# The default client runs inside db-test, so it must use PostgreSQL's internal
# port. The Go integration suite uses the host-mapped 55432 port separately.
DATABASE_URL="${MIGRATION_DATABASE_URL:-${DATABASE_URL:-postgres://postgres:postgres@localhost:5432/notes_app_test?sslmode=disable}}"
COMPOSE="${COMPOSE:-docker compose}"
PSQL_COMMAND="${PSQL_COMMAND:-$PROJECT_ROOT/harness/scripts/tests/psql-test-client.sh}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_psql() {
  # PSQL_COMMAND intentionally supports a compose exec command with arguments.
  $PSQL_COMMAND "$DATABASE_URL" -v ON_ERROR_STOP=1 "$@"
}

query() {
  run_psql -Atqc "$1" | tr -d '\r'
}

run_migrate() {
  make DATABASE_URL="$DATABASE_URL" PSQL="$PSQL_COMMAND" migrate
}

echo "Preparing an existing schema without migration metadata or 0005 columns..."
run_psql -c 'DROP TABLE IF EXISTS schema_migrations; ALTER TABLE note_block_comments DROP COLUMN IF EXISTS mentions, DROP COLUMN IF EXISTS parent_comment_id;'

[ "$(query "SELECT to_regclass('public.schema_migrations') IS NOT NULL")" = "f" ] || \
  fail "schema_migrations unexpectedly existed before the adoption check"
[ "$(query "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'note_block_comments' AND column_name = 'mentions')")" = "f" ] || \
  fail "mentions unexpectedly existed before the upgrade check"

echo "Running migration adoption and upgrade check..."
first_run="$(run_migrate)"
printf '%s\n' "$first_run"
[[ "$first_run" == *"Applying migrations/0005_add_note_block_comment_metadata.up.sql"* ]] || \
  fail "migration runner did not apply the pending 0005 migration"

[ "$(query 'SELECT COUNT(*) FROM schema_migrations')" = "5" ] || \
  fail "migration runner did not record all five migrations"
[ "$(query "SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'note_block_comments' AND column_name = 'parent_comment_id') AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'note_block_comments' AND column_name = 'mentions')")" = "t" ] || \
  fail "migration runner did not restore the 0005 schema"

echo "Running repeatability check..."
second_run="$(run_migrate)"
printf '%s\n' "$second_run"
skip_count="$(printf '%s\n' "$second_run" | awk '/^Skipping migrations\/[0-9]+.*\.up\.sql/ { count++ } END { print count + 0 }')"
apply_count="$(printf '%s\n' "$second_run" | awk '/^Applying migrations\/[0-9]+.*\.up\.sql/ { count++ } END { print count + 0 }')"
[ "$skip_count" = "5" ] || fail "repeat migration run skipped $skip_count migrations instead of 5"
[ "$apply_count" = "0" ] || fail "repeat migration run applied $apply_count migrations"

echo "PASS: migration runner upgrades an existing PostgreSQL schema and is repeat-safe."
