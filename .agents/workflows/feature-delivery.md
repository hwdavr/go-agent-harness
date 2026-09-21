---
description: Deliver a backend feature through requirements, approved planning, implementation, testing, and quality gates.
---

# Workflow: Feature delivery

Use this for a new endpoint, domain capability, persistence change, or
meaningful enhancement.

Pipeline: context → requirement/spec → implementation and test plan → user
approval → implementation → tests → quality gate → delivery record.

1. Read `AGENTS.md`, `architecture.md`, and `testing-strategy.md`. Load
   `api-contract.md`, `security.md`, or database guidance when triggered.
2. Create `docs/current/spec_v<N>.md` and `summary_v<N>.md`. Record scope,
   exclusions, impacted layers, acceptance criteria, and the complete Rule
   Applicability table from `harness/templates/rule-applicability-template.md`.
3. Create `implementation_plan_v<N>.md` and `test_plan_v<N>.md`. Run:
   `bash harness/scripts/check-stage-artifacts.sh feature-delivery implementation-plan`.
4. Stop for explicit user approval before implementation for non-trivial work.
5. Implement the smallest vertical slice: contract/handler, domain behavior,
   persistence, then tests as required by the plan.
6. Run `make check`; run `make test-integration` when the plan requires the
   PostgreSQL boundary. Record commands, exit status, test counts, and evidence
   in `summary_v<N>.md`.
7. Update `docs/product/product.md` and add a durable note under
   `docs/changes/` when the change is delivered.
