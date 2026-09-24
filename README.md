# Notes App Backend Agent Harness

This directory contains the backend version of the agent harness used by the
NotesTakingApp projects. It keeps the useful parts of the mobile harness—small
context layers, explicit workflows, stage artifacts, and executable gates—but
uses Go, Chi, PostgreSQL, Auth0, and OpenAPI rules appropriate to this service.

## Quick start

Run the initializer once from the repository root:

```bash
bash .harness/harness/scripts/init-harness.sh
```

Then use the normal quality gate:

```bash
make check
```

The harness does not install dependencies, modify credentials, start a database,
or schedule an agent automatically. `make up` is the explicit local Docker
stack entry point; `make test` is deterministic and does not require Docker.

## What is enforced

- `AGENTS.md` is the root context map for every coding session.
- `.agents/rules/` describes the service architecture, testing, security, and
  implementation constraints.
- `.agents/workflows/` routes feature, bug-fix, API-contract, and review work.
- `harness/scripts/check-full-source-rules.sh` runs formatting, vet, tests,
  architecture checks, OpenAPI checks, and migration checks.
- `docs/product/product.md` is the lifecycle tracker for larger work.
- `docs/product/YYYY-MM-DD-feature/` is the required, dated workspace for a
  feature, bug, contract update, or review; `docs/changes/` is the durable
  delivery record.

## Context layers

| Layer | Load when | Contents |
| --- | --- | --- |
| L1 | Every session | `AGENTS.md`, architecture, testing strategy |
| L2 | A workflow stage | The active workflow skill and relevant security/API/database rules |
| L3 | Needed by the task | OpenAPI, migrations, knowledge records, and feature evidence |

Do not preload the whole repository or every rule. The point of the harness is
to make the smallest useful context and the strongest relevant verification
explicit.
