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

## Development-loop environment

The authoritative [testing strategy](.agents/rules/testing-strategy.md) covers
five ordered gates: static, targeted unit, component/API, integration, regression.
It includes scenario design, fixture isolation, contract verification, and
failure/repair/revalidation. The workflows and artifact templates require agents
to plan and record these gates. No new application tests, runner, contract tools,
or infrastructure are installed by this environment enhancement.

- [Project capability profile](../docs/product/project-capabilities.json): actual Notes
  App capabilities, existing command limits, and missing verification tooling.
- [Kafka rules](.agents/rules/messaging-testing.md) and
  [Kafka testing skill](.agents/skills/messaging-testing/SKILL.md): applicability
  policy plus producer/consumer scenario procedure.
- [Idempotency rules](.agents/rules/idempotency-testing.md) and
  [idempotency testing skill](.agents/skills/idempotency-testing/SKILL.md):
  applicability policy plus HTTP/consumer retry procedure.
- [Test plan template](harness/templates/test-plan-template.md): applicability,
  selected packages/scenarios, real/mocked dependencies, and ordered commands.
- Each feature's test plan derives its Required/Not required matrix from that
  feature's spec. The project capability profile only records project-wide
  tools and infrastructure; it does not decide a feature's test requirements.
- [Evidence guide](harness/verification-evidence.md) and
  [JSON template](harness/templates/verification-evidence-template.json): manual
  structured command and assertion receipts, with precise status semantics.

Kafka and idempotency are planning capabilities, not active Notes App features.
The profile is agent-read metadata, not executable configuration. An unsupported
required check is BLOCKED; a scope-excluded capability is NOT_APPLICABLE with a
reason. Do not claim that existing OpenAPI path checks validate response schemas
or that `make check` implements an automatic fail-fast five-gate pipeline.

## Reuse in another Go project

1. Copy the [profile template](harness/templates/project-capabilities-template.json)
   into that project's harness and decide capabilities from its requirements.
2. Inventory real commands and their limitations. Adapt project-specific paths,
   architecture/API conventions, and runtime setup; the existing Notes App shell
   scripts are not generic Kafka or database adapters.
3. Use the shared strategy and load optional rules only for relevant work.
4. Plan missing tests/tools as separately authorized implementation work. A
   template or declared capability never substitutes for executable evidence.

Release-loop performance/security/deployment/full-system E2E remains excluded.

## Complex feature planning and multi-slice delivery

Use `harness-planning.md` for a large feature. It first resolves material open
questions and creates a parent specification for user review. After the spec is
accepted, it creates and approves the parent implementation plan, test plan, and
`feature_list.json`. The feature list maps each slice to scope, dependencies,
parent requirement IDs, acceptance IDs, and required test case IDs. Run
`harness-generator.md` with a slice ID to deliver that slice. If no slice ID is
supplied, it selects one ready slice by priority, then slice ID, after all of its
dependencies pass. Each generator run records its steps and delivery evidence in
`summary_<slice-id>.MD` directly in the dated feature workspace, then marks the
slice `passing`, `blocked`, or `needs_fix`.

When all slices are passing, move the parent tracker entry to `To be reviewed`,
run the lifecycle checker, then use `harness-review.md` for the parent and
aggregate slice review. Single-slice work continues through `feature-review.md`
after `feature-delivery.md` or `bug-fixing.md`.

## Context layers

| Layer | Load when | Contents |
| --- | --- | --- |
| L1 | Every session | `AGENTS.md`, architecture, testing strategy |
| L2 | A workflow stage | The active workflow skill and relevant security/API/database rules |
| L3 | Needed by the task | OpenAPI, migrations, knowledge records, and feature evidence |

Do not preload the whole repository or every rule. The point of the harness is
to make the smallest useful context and the strongest relevant verification
explicit.
