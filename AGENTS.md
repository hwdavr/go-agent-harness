# AGENTS.md

This is the backend harness context map. Read it first, then load only the
workflow and rules needed for the current task.

## Project

Go 1.22 HTTP backend for the NotesTakingApp. It uses Chi, PostgreSQL, Bob,
Auth0 JWT validation, SQL migrations, and an OpenAPI contract.

Module map:

- `cmd/server/` — process startup and dependency wiring.
- `internal/config/` — environment-backed configuration.
- `internal/http/` — router, middleware, and transport handlers.
- `internal/domain/` — domain models, services, repository contracts and the
  current PostgreSQL repository implementation.
- `internal/db/` — database connection and generated Bob models.
- `internal/pkg/` — narrowly scoped shared packages.
- `migrations/` — paired `.up.sql` and `.down.sql` migrations.
- `openapi.yaml` — the HTTP contract shared with clients.

## Context loading

| Layer | When | Load |
| --- | --- | --- |
| L1 | Every session | This file, `architecture.md`, `testing-strategy.md` |
| L2 | Per workflow stage | The selected workflow skill and triggered rules |
| L3 | When needed | OpenAPI, migrations, knowledge, and feature evidence |

If the host disallows the conventional root `.agents` symlink, use the
equivalent `.harness/.agents/` path; `harness/` remains the root entry point.

## Harness structure

- `.agents/workflows/` — task routing and stage gates.
- `.agents/rules/` — mandatory engineering constraints.
- `.agents/skills/` — stage-specific how-to guidance.
- `harness/templates/` — specs, plans, summaries, and review records.
- `harness/scripts/` — executable quality and lifecycle checks.
- `docs/product/` — product capabilities, feature tracker, and dated feature
  workspaces under `docs/product/YYYY-MM-DD-feature/`.
- `docs/changes/` — durable delivery notes.

## Workflow routing

Before changing code, identify the task type and read the matching workflow in
full:

- New endpoint or enhancement: `.agents/workflows/feature-delivery.md`.
- Bug, regression, or failing test: `.agents/workflows/bug-fixing.md`.
- OpenAPI or shared client contract change: `.agents/workflows/api-contract-update.md`.
- Independent pre-merge review: `.agents/workflows/feature-review.md`.
- Every feature, bug, contract update, and review: use a dated workspace under
  `docs/product/YYYY-MM-DD-feature/`; multi-slice work also maintains a
  `feature_list.json` there.

## Non-negotiable rules

- Never commit credentials, tokens, private keys, or real user data.
- Keep HTTP parsing/auth/error mapping in `internal/http`; keep business rules
  in `internal/domain`; keep SQL and generated models behind the repository.
- Handlers must not import `internal/db/models` or execute SQL directly.
- Every changed endpoint needs focused tests and an OpenAPI update when its
  request, response, status, or path contract changes.
- Every schema change has a matching rollback migration. Docker bootstrap must
  execute only `.up.sql` files.
- Do not log bearer tokens, JWT claims containing PII, note content, or raw
  database URLs. Wrap external calls with context and bounded timeouts.
- Do not edit generated Bob files by hand; regenerate them from the schema.
- Do not use `TODO`, `panic("not implemented")`, or silent stub behavior in
  production code.
- Run `make check` before handoff. A warning, skipped test, or unavailable
  database is not passing evidence for a claim that requires that runtime.
- For non-trivial work, obtain approval of the versioned implementation plan
  before implementation and record command, status, and evidence in the
  versioned summary.

## Standard commands

```bash
make test          # deterministic Go tests
make check         # full source, contract, migration, vet, and test gate
make up            # Docker Postgres + backend
make down          # stop the Docker stack
make logs          # follow backend logs
```
